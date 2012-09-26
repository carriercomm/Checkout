class Kit < ActiveRecord::Base

  ## Macros ##

  resourcify
  strip_attributes


  ## Callbacks ##

  before_validation :handle_tombstoned


  ## Associations ##

  belongs_to :budget,           :inverse_of => :kits
  has_many   :clients,          :through => :reservations
  has_many   :component_models, :through => :components, :order => "component_models.name ASC"
  has_many   :components,       :inverse_of => :kit
  has_many   :groups,           :through => :permissions, :order => "groups.name ASC"
  belongs_to :location,         :inverse_of => :kits
  has_many   :permissions,      :inverse_of => :kit
  has_many   :reservations,     :inverse_of => :kit

  accepts_nested_attributes_for :components, :reject_if => proc { |attributes| attributes['component_model_id'].blank? }, :allow_destroy=> true


  ## Validations ##

  validates_presence_of :location
  validate :should_have_at_least_one_component
  validate :tombstoned_should_not_be_checkoutable


  ## Mass-assignable attributes ##

  attr_accessible(:budget_id,
                  :checkoutable,
                  :components_attributes,
                  :cost,
                  :insured,
                  :location_id,
                  :tombstoned)

  ## Virtual Attributes ##

  attr_reader :forced_not_checkoutable


  ## Named scopes ##

  scope :checkoutable,       where("kits.tombstoned = ? AND kits.checkoutable = ?", false, true)
  scope :missing_components, joins(:components).where("kits.tombstoned = ? AND components.missing = ?", false, true)
  scope :non_checkoutable,   where("kits.tombstoned = ? AND kits.checkoutable = ?", false, false)
  scope :tombstoned,         where("kits.tombstoned = ?", true)


  ## Class Methods ##

  def self.asset_tag_search(query)
    includes(:components).joins(:components)
      .where("components.asset_tag LIKE ?", "%#{ query }%")
      .order("components.asset_tag ASC")
  end

  ## Instance Methods ##

  # returns an array of asset tags from components
  def asset_tags
    at = components.collect { |c| (c.asset_tag.blank?) ? nil : c.asset_tag }
    return at.compact
  end

  def checked_out?
    reservations.where("reservations.out_at < ? AND reservations.end_at > ?", Date.today, Date.today).count > 0
  end

  def checkoutable?
    return checkoutable && !tombstoned
  end

  # equal to location.open_days minus days_reserved returns in format
  # [[month, day], [month, day], ...] for consumption by the
  # javascript date picker
  def days_reservable(days_out = 90)
    return location.open_days(days_out) - days_reserved(days_out)
  end

  # returns in format [[month, day], [month, day], ...] for
  # consumption by the javascript date picker
  def days_reserved(days_out = 90)
    days = []
    start_range = Time.now.at_beginning_of_day
    end_range   = start_range + days_out.days
    time_range  = (start_range..end_range)
    reservations.where(:start_at => time_range).all.each do |r|
      start_range = r.start_at.to_date
      end_range   = r.end_at.to_date
      (start_range..end_range).each do |date|
        days.concat([date.month, date.day])
      end
    end
    return days
  end

  # before_validation callback:
  # ensure that anything tombstoned is not checkoutable
  def handle_tombstoned
    if tombstoned && checkoutable
      self.checkoutable = false
      @forced_not_checkoutable = true
    end
    return true
  end

  # by convention, we use this as the kit descriptor
  # def primary_component
  #   components.joins(:model).order("position").first
  # end

  # by convention, we use this as the kit descriptor
  # def primary_model
  #   primary_component.component_model
  # end

  # TODO: add check for permissions
  # TODO: add check for 'hold'
  def reservable?
    checkoutable
  end

  # TODO: enforce the should_have_at_least_one_component at all times
  # def save
  #   saved = false
  #   ActiveRecord::Base.transaction do
  #     saved = super
  #     if self.conditions.size < 1
  #       saved = false
  #       errors[:base] << "A rule must have at least one condition."
  #       raise ActiveRecord::Rollback
  #     end
  #   end
  #   saved
  # end

  # TODO: test this
  def training_required?
    @training_required ||= uncached_training_required?
  end

  # custom validator
  def should_have_at_least_one_component
    if components.length < 1
      errors[:base] << "Kit should have at least one component"
    end
  end

  # TODO: fix this
  # def to_param
  #   "#{ id } #{ to_s }".parameterize
  # end

  # def to_s
  #   "#{ primary_model.brand } #{ primary_model }"
  # end

  # custom validator
  def tombstoned_should_not_be_checkoutable
    if tombstoned && checkoutable
      errors[:base] << "Kit cannot be tombstoned AND checkoutable"
    end
  end

  def uncached_training_required?
    components.each do |c|
      return true if c.training_required?
    end
    return false
  end

end
