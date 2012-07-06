class Kit < ActiveRecord::Base

  belongs_to :budget
  belongs_to :location
  belongs_to :model
  has_many   :components
  has_many   :reservations
  has_many   :clients, :through => :reservations
  # has_and_belongs_to_many :groups

  validates :location_id, :presence => true
  validate  :should_have_at_least_one_component
  validate  :tombstoned_should_not_be_checkoutable

  before_validation :handle_tombstoned

  attr_accessible :budget_id, :checkoutable, :cost, :insured, :location_id, :model_id, :tombstoned

  def asset_tags
    component_tags = components.collect do |c|
      c.asset_tags.collect { |at| at.uid }
    end
    return component_tags.flatten
  end

  # equal to location.open_days minus days_reserved returns in format
  # [[month, day], [month, day], ...] for consumption by the
  # javascript date picker
  def days_reservable(days_out = 90)
    return location.open_days(days_out) - days_reserved(days_out)
  end

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

  # ensure that anything tombstoned is not checkoutable
  def handle_tombstoned
    checkoutable = false if tombstoned
  end

  def should_have_at_least_one_component
    if components.count < 1
      errors[:base] << "Kit should have at least one component"
    end
  end

  def summary
    "#{ self.to_s} (#{ asset_tags.join(', ') })"
  end

  def to_param
    "#{ id } #{ model.brand } #{ model }".parameterize
  end

  def to_s
    "#{ model.brand } #{ model }"
  end

  def tombstoned_should_not_be_checkoutable
    if tombstoned && checkoutable
      errors[:base] << "Kit cannot be tombstoned AND checkoutable"
    end
  end

end
