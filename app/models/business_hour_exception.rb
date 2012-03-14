class BusinessHourException < ActiveRecord::Base
  belongs_to :location

  validates :location_id, :presence => true
  validates :date_closed, :presence => true

  default_scope order("location_id ASC, date_closed ASC")

  def day
    date_closed.strftime('%e')
  end

  def day_sym
    day.downcase.to_sym
  end

  def month
    date_closed.strftime('%-m')
  end

  def to_a
    [month.to_i, day.to_i]
  end

end
