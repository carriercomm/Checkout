class Location < ActiveRecord::Base
  has_many :kits
  has_many :business_hours

  validates :name, :uniqueness => true

  accepts_nested_attributes_for :business_hours, :reject_if => :all_blank, :allow_destroy=> true

  # TODO: enforce some referential integrity so you can't delete a location and orphan all its kits

  def open_days(days_out = 90)
    days = []
    business_hours.each { |x| days.concat(x.open_occurrences(days_out)) }
    return days
  end

end
