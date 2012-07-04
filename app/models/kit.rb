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
  # TODO: validate that kits are not tombstoned AND checkoutable - need to fix up dBx data first

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
    reservations.where(:start_at => (start_range..end_range)).all.each do |r|
      (r.start_at..r.end_at).each do |date|
        days.concat([date.month, date.day])
      end
    end
    return days
  end

  def should_have_at_least_one_component
    if components.count < 1
      errors[:base] << "Kit should have at least one component"
    end
  end

  def to_s
    "#{ model.brand } #{ model } (#{ asset_tags.join(', ') })"
  end

end
