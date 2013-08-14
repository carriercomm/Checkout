class Kit < ActiveRecord::Base

  ## Macros ##

  strip_attributes


  ## Callbacks ##

  before_validation :handle_tombstoned


  ## Associations ##

  has_many   :audit_inventory_records,     :inverse_of => :kit
  belongs_to :budget,                      :inverse_of => :kits
  has_many   :check_in_inventory_records,  :inverse_of => :kit
  has_many   :check_out_inventory_records, :inverse_of => :kit
  has_many   :clients,                     :through    => :loans
  has_many   :component_models,            :through    => :components,  :order => "component_models.name ASC"
  has_many   :components,                  :inverse_of => :kit,         :order => "components.position ASC",  :include => [:component_model => :brand]
  has_many   :groups,                      :through    => :permissions, :order => "groups.name ASC"
  has_many   :inventory_records,           :inverse_of => :kit
  belongs_to :location,                    :inverse_of => :kits
  has_many   :permissions,                 :inverse_of => :kit
  has_many   :loans,                       :inverse_of => :kit

  accepts_nested_attributes_for :components, :reject_if => proc { |attributes| attributes['component_model_id'].blank? }, :allow_destroy=> true


  ## Validations ##

  validates_presence_of :location
  validate :should_have_at_least_one_component
  validate :tombstoned_should_not_be_circulating


  ## Mass-assignable attributes ##

  attr_accessible(:budget_id,
                  :circulating,
                  :components_attributes,
                  :cost,
                  :insured,
                  :location_id,
                  :tombstoned)

  ## Virtual Attributes ##

  attr_reader :forced_not_circulating


  ## Named scopes ##

  scope :circulating,       where("kits.tombstoned = ? AND kits.circulating = ?", false, true)
  scope :missing_components, joins(:components).where("kits.tombstoned = ? AND components.missing = ?", false, true)
  scope :non_circulating,   where("kits.tombstoned = ? AND kits.circulating = ?", false, false)
  scope :tombstoned,         where("kits.tombstoned = ?", true)


  ## Class Methods ##

  def self.asset_tag_search(query)
    includes(:components)
      .joins(:components)
      .where("LOWER(components.asset_tag) LIKE ?", "%#{ query.downcase }%")
      .order("components.asset_tag ASC")
  end

  # finds a specific asset tag
  # not fuzzy like asset_tag_search
  def self.find_by_asset_tag(asset_tag)
    Component.find_by_asset_tag(asset_tag.to_s).try(:kit)
  end

  def self.id_search(query)
    where("CAST(kits.id AS TEXT) LIKE ?", "%#{ query }%")
      .order("kits.id ASC")
  end

  # returns any loans which overlap with the start and end dates
  # passed as parameters
  def self.loaned_between(start_range, end_range)
    includes(:loans)
      .joins(:loans)
      .where("(loans.starts_at BETWEEN ? AND ?) OR (loans.ends_at BETWEEN ? AND ?)", start_range, end_range, start_range, end_range)
  end

  ## Instance Methods ##

  # adds a component of type component_model to the kit
  def add_component(component_model)
    components << Component.create(component_model_id: component_model.id)
  end

  # returns an array of asset tags from components
  def asset_tags
    at = components.collect { |c| (c.asset_tag.blank?) ? nil : c.asset_tag }
    return at.compact
  end

  def available?(start_date, end_date, *excluded_loans)
    circulating? && loans.with_lost_state.empty? && !loaned_between?(start_date, end_date, excluded_loans.flatten)
  end

  def checked_out?
    loans.where("loans.out_at < ? AND loans.ends_at > ?", Date.today, Date.today).count > 0
  end

  def circulating?
    return circulating && !tombstoned
  end

  # def components_denormalized
  #   select_sql = "components.*, inventory_details.missing"
  #   joins_sql  = <<-END_SQL
  #   left join inventory_details on components.id = inventory_details.component_id
  #   inner join (
  #               select max(id) as max_id
  #               from inventory_records
  #               where inventory_records.kit_id = #{ self.id }
  #               ) AS t1 ON inventory_details.inventory_record_id = t1.max_id
  #   inner join component_models on components.component_model_id = component_models.id
  #   inner join brands on component_models.brand_id = brands.id
  #   END_SQL

  #   components.select(select_sql).joins(joins_sql)
  # end

  def default_return_date(starts_at)
    default = Settings.default_check_out_duration
    time    = (starts_at + default.days)
    time    = Time.local(time.year, time.month, time.day, time.hour, time.min, time.sec)
    location.next_time_open(time).to_datetime
  end

  def first_available_date
    nexts = []
    schedules_of_availability.each do |s|
      # should today be included?
      if s.occurring_between?(Time.zone.now, Time.zone.now.end_of_day)
        ref_time = Time.zone.now.at_beginning_of_day
      else
        ref_time = Time.zone.now
      end
      nexts << s.next_occurrence(ref_time)
    end
    nexts.sort.first
  end

  # before_validation callback:
  # ensure that anything tombstoned is not circulating
  def handle_tombstoned
    if tombstoned && circulating
      self.circulating = false
      @forced_not_circulating = true
    end
    return true
  end

  # returns the start dates for each loan
  # def hard_return_dates_for_datepicker(days_out = 90, *excluded_loans)
  #   excluded_loans.flatten!
  #   dates = []

  #   # build up params for where clause
  #   start_range = Time.now.at_beginning_of_day
  #   end_range   = start_range + days_out.days

  #   # iterate over the set of loans in this range
  #   loans_between(start_range, end_range, excluded_loans).all.each do |r|
  #     dates << r.starts_at.to_date
  #   end
  #   dates.uniq!

  #   return dates.collect { |d| d.to_s(:js) }
  # end

  # returns a record for this kit (without location info), to populate into
  # gon for the datepicker
  def kit_record_for_datepicker(days_out = 90, *excluded_loans)
    excluded_loans.flatten!
    {
      'kit_id' => id,
      'pickup_dates' => pickup_times_for_datepicker(days_out, excluded_loans)
    }
  end

  # returns all the loans that overlap with the range specified by the
  # start and end dates
  def loans_between(start_date, end_date, *excluded_loans)
    excluded_loans.flatten!
    sql = "((loans.starts_at BETWEEN :start AND :end) OR (loans.ends_at BETWEEN :start AND :end))"

    unless excluded_loans.empty?
      sql << " AND loans.id NOT IN (:ids)"
    end

    loans.where(sql,
              :start => start_date,
              :end => end_date,
              :ids => excluded_loans.map(&:id))
  end

  # returns the dates this kit is loaned within the time range
  # specified - not including the end date, since the
  # thing should be on the shelf at some point on those days
  def loan_blackout_dates(days_out = 90, *excluded_loans)
    excluded_loans.flatten!
    dates = []

    # build up params for where clause
    start_range = Time.now.at_beginning_of_day
    end_range   = start_range + days_out.days

    # iterate over the set of loans in this range
    loans_between(start_range, end_range, excluded_loans).all.each do |r|
      starts_at = r.starts_at.to_date
      ends_at   = r.ends_at.to_date

      # add a day for every day in the range (except the end date)
      (starts_at...ends_at).each do |date|
        dates << date
      end
    end
    return dates.uniq
  end

  def loan_blackout_dates_for_datepicker(days_out = 90, *excluded_loans)
    excluded_loans.flatten!
    loan_blackout_dates(days_out, excluded_loans).collect { |d| d.to_s(:js) }
  end

  def loaned_between?(start_date, end_date, excluded_loans)
    !loans_between(start_date, end_date, excluded_loans).empty?
  end

  # returns the full data structure to populate into gon for the datepicker
  def location_and_availability_record_for_datepicker(days_out = 90, *excluded_loans)
    excluded_loans.flatten!
    {
      location.id => {
        'kits' => [kit_record_for_datepicker(days_out, excluded_loans)]
      }
    }
  end

  # TODO: add check for 'hold'
  def permissions_include?(client)
    client && circulating? && (client.admin? || groups.map(&:users).flatten.uniq.include?(client))
  end

  # equal to location.open_days minus days_reserved returns in format
  # [[month, day], [month, day], ...] for consumption by the
  # javascript date picker
  def pickup_times_for_datepicker(days_out = 90, *excluded_loans)
    excluded_loans.flatten!
    times = pickup_times(days_out, excluded_loans)
    times.map! { |d| d.to_s(:js) }
    return times
  end

  def pickup_times(days_out = 90, *excluded_loans)
    excluded_loans.flatten!
    occurrences = []

    schedules_of_availability(excluded_loans).each do |s|
      # should today be included?
      if s.occurring_between?(Time.zone.now, Time.zone.now.end_of_day)
        end_time = Time.zone.now.at_beginning_of_day + days_out.days
      else
        end_time = Time.zone.now.end_of_day + days_out.days
      end
      occurrences.concat(s.occurrences(end_time))
    end

    occurrences.map!(&:to_time).sort!
    return occurrences
  end

  def requires_client_training?(client)
    component_models.where(training_required: true).each { |c| return true if c.requires_client_training?(client) }
    false
  end

  alias_method :reservable?, :permissions_include?

  # def return_dates_for_datepicker(days_out = 90, *excluded_loans)
  #   excluded_loans.flatten!
  #   return_dates = []
  #   next_loan_date = dates_loaned_for_datepicker(days_out, excluded_loans).first

  #   # iterate over the dates, adding them to the return dates, until
  #   # we get to the next return date
  #   location.dates_open_for_datepicker(days_out).each do |date|
  #     return_dates << date
  #     break if date == next_loan_date
  #   end

  #   return_dates
  # end

  def schedules_of_availability(*excluded_loans)
    lbd = loan_blackout_dates(365, excluded_loans)

    schedules = location.schedules

    schedules.each do |s|
      lbd.each do |date|
        if s.occurs_on?(date)
          year   = date.year
          month  = date.month
          day    = date.day
          hour   = s.start_time.hour
          minute = s.start_time.min
          except = Time.zone.local(year, month, day, hour, minute)
          s.add_exception_time(except)
        end
      end
    end

    return schedules

  end

  # custom validator
  def should_have_at_least_one_component
    if components.length < 1
      errors[:base] << "Kit should have at least one component"
    end
  end

  def to_s
    "#{ id.to_s } | #{asset_tags.join(", ")} | #{ components.map(&:component_model).map(&:to_branded_s).join(", ") }"
  end

  # custom validator
  def tombstoned_should_not_be_circulating
    if tombstoned && circulating
      errors[:base] << "Kit cannot be tombstoned AND circulating"
    end
  end

  def training_required?
    !component_models.where(training_required: true).empty?
  end

end
