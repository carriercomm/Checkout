class Kit < ActiveRecord::Base

  belongs_to :location
  has_many   :parts
  has_many   :models, :through => :parts
  has_many   :reservations
  has_many   :clients, :through => :reservations
  # has_and_belongs_to_many :groups

  validates :location_id, :presence => true
  validate  :should_have_at_least_one_part
  # TODO: validate that kits are not tombstoned AND checkoutable - need to fix up dBx data first

  default_scope order("kits.name ASC")

  attr_accessible :name, :location_id, :tombstoned, :checkoutable

  def should_have_at_least_one_part
    if parts.count < 1
      errors[:base] << "Kit should have at least one part"
    end
  end

  def days_reservable(days_out = 90)
    checkout_hours = location.open_days(days_out)
    
  end

  def days_reserved(days_out = 90)

  end

  def to_s
    name
  end

end
