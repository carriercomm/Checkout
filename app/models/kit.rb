class Kit < ActiveRecord::Base

  ## Mixins ##

  include Workflow


  ## Macros ##

  strip_attributes

  workflow do
    state :non_circulating do
      event :circulate,              :transitions_to => :circulating
      event :deaccession,            :transitions_to => :deaccessioned
    end

    state :circulating do
      event :become_non_circulating, :transitions_to => :non_circulating
      event :deaccession,            :transitions_to => :deaccessioned
    end

    state :deaccessioned do
      event :circulate,              :transitions_to => :circulating
      event :become_non_circulating, :transitions_to => :non_circulating
    end
  end


  ## Associations ##

  has_many   :audit_inventory_records,     :inverse_of => :kit
  has_many   :check_in_inventory_records,  :inverse_of => :kit
  has_many   :check_out_inventory_records, :inverse_of => :kit
  has_many   :clients,                     :through    => :loans
  has_many   :component_models,            :through    => :components,  :order => "component_models.name ASC"
  has_many   :components,                  :inverse_of => :kit,         :order => "components.position ASC",  :include => [:component_model => :brand]
  belongs_to :custodian,                   :inverse_of => :kits,        :class_name => "User"
  has_many   :groups,                      :through    => :permissions, :order => "groups.name ASC"
  has_many   :inventory_records,           :inverse_of => :kit
  belongs_to :location,                    :inverse_of => :kits
  has_many   :permissions,                 :inverse_of => :kit
  has_many   :loans,                       :inverse_of => :kit

  accepts_nested_attributes_for :components, :reject_if => proc { |attributes| attributes['component_model_id'].blank? }, :allow_destroy=> true


  ## Validations ##

  # TODO: if the kit is circulating, it's location must have business hours? Maybe better to just post a warning back the user
  validates :location,       :presence => true
  validates :workflow_state, :presence => true
  validate  :should_have_at_least_one_component


  ## Mass-assignable attributes ##

  attr_accessible(:components_attributes,
                  :cost,
                  :custodian_id,
                  :location_id,
                  :workflow_state)


  ## Class Methods ##

  def self.asset_tag_search(query)
    includes(:components)
      .joins(:components)
      .where("LOWER(components.asset_tag) LIKE ?", "%#{ query.downcase }%")
      .order("components.asset_tag ASC")
  end

  def self.circulating_for_user(user)
    for_user(user).with_circulating_state.uniq
  end

  def self.for_user(user)
    joins(:groups => :users).where("users.id = ?", user.id).uniq
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

  def self.with_missing_components
    joins_sql = <<-END_SQL
    INNER JOIN inventory_records ON kits.id = inventory_records.kit_id
    INNER JOIN (SELECT kit_id, max(created_at) as max_created_at
                FROM inventory_records
                GROUP BY kit_id) AS t1 ON (t1.kit_id = inventory_records.kit_id AND t1.max_created_at = inventory_records.created_at)
    INNER JOIN inventory_details ON inventory_records.id = inventory_details.inventory_record_id
    END_SQL

    joins(joins_sql).where("inventory_details.missing = ? AND kits.workflow_state <> 'deaccessioned'", true)
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
    loans.with_lost_state.empty? && !loaned_between?(start_date, end_date, excluded_loans.flatten)
  end

  #
  # TODO: implement methods for loan status of this kit
  #
  def checked_out?
    now = DateTime.current
    !loans.where("loans.workflow_state = \'checked_out\' AND loans.out_at <= ? AND loans.ends_at >= ?", now, now).empty?
  end

  def currently_checked_out_loan
    now = DateTime.current
    loans.where("loans.workflow_state = \'checked_out\' AND loans.out_at <= ? AND loans.ends_at >= ?", now, now).first
  end

  def default_return_date(starts_at)
    return nil unless starts_at
    default = Settings.default_loan_duration
    time    = (starts_at + default.days)
    time    = Time.local(time.year, time.month, time.day, time.hour, time.min, time.sec)
    nto     = location.next_datetime_open(time)
    if nto
      return nto.to_datetime
    else
      return time.to_datetime
    end
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
    client && circulating? && (client.admin? || groups_include?(client))
  end

  # Overriding Workflow's default active_record behavior:
  # We might move through several states in a given controller action,
  # so avoid the database roundtrip. Call save explicitly to persist.
  # TODO: make this method private (after import is done)
  def persist_workflow_state(new_state)
    write_attribute self.class.workflow_column, new_state.to_s
  end

  # equal to location.open_days minus days_requested returns in format
  # [[month, day], [month, day], ...] for consumption by the
  # javascript date picker
  def pickup_times_for_datepicker(days_out = 90, *excluded_loans)
    excluded_loans.flatten!
    times = pickup_times(days_out, excluded_loans)
    return times.map { |d| d.to_s(:js) }
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

  alias_method :requestable?, :permissions_include?

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

  def to_s
    "#{ id.to_s } | #{asset_tags.join(", ")} | #{ components.map(&:component_model).map(&:to_branded_s).join(", ") }"
  end

  def training_required?
    !component_models.where(training_required: true).empty?
  end

  private

  # this is a callback which is invoked when become_non_circulating! is called
  def become_non_circulating
    permissions.delete_all
  end

  # user permissions_include? since it has greater checks
  def groups_include?(user)
    !self.class.for_user(user).where("kits.id = ?", self.id).empty?
  end

  # custom validator
  def should_have_at_least_one_component
    if components.empty?
      errors[:base] << "Kit should have at least one component"
    end
  end

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
