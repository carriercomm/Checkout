class BusinessHourException < ActiveRecord::Base

  #
  # Associations
  #

  belongs_to :location, :inverse_of => :business_hour_exceptions


  #
  # Validations
  #

  validates_presence_of :location
  validates :date_closed, :presence => true


  #
  # Mass-assignable attributes
  #

  attr_accessible(:location_id, :location, :date_closed)


  #
  # Instance Methods
  #

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
