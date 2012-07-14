class Kit < ActiveRecord::Base

  #
  # Callbacks
  #

  before_validation :handle_tombstoned


  #
  # Associations
  #

  belongs_to :budget,       :inverse_of => :kits
  has_many   :clients,      :through => :reservations
  has_many   :components,   :inverse_of => :kit
  belongs_to :location,     :inverse_of => :kits
  has_many   :models,       :through => :components
  has_many   :reservations, :inverse_of => :kits
  # has_and_belongs_to_many :groups


  #
  # Validations
  #

  validates_presence_of :location
  validate :should_have_at_least_one_component
  validate :tombstoned_should_not_be_checkoutable


  #
  # Mass-assignable attributes
  #

  attr_accessible(:budget_id,
                  :checkoutable,
                  :cost,
                  :insured,
                  :location_id,
                  :tombstoned)


  #
  # Named scopes
  #

  scope :checkoutable,     where("kits.tombstoned = ? AND kits.checkoutable = ?", false, true)
  scope :not_checkoutable, where("kits.tombstoned = ? OR kits.checkoutable = ?", true, false)
  scope :tombstoned,       where("kits.tombstoned = ?", true)


  #
  # Instance Methods
  #

  def asset_tags
    components.collect { |c| c.asset_tag }
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
    self.checkoutable = false if tombstoned
    return true
  end

  # by convention, we use this as the kit descriptor
  def primary_component
    components.joins(:model).order("position").first
  end

  # by convention, we use this as the kit descriptor
  def primary_model
    primary_component.model
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

  # custom validator
  def should_have_at_least_one_component
    if components.length < 1
      errors[:base] << "Kit should have at least one component"
    end
  end

  def to_param
    "#{ id } #{ to_s }".parameterize
  end

  def to_s
    "#{ primary_model.brand } #{ primary_model }"
  end

  # custom validator
  def tombstoned_should_not_be_checkoutable
    if tombstoned && checkoutable
      errors[:base] << "Kit cannot be tombstoned AND checkoutable"
    end
  end

end
