class BusinessHourException < ActiveRecord::Base

  ## Macros ##

  resourcify


  ## Associations ##

  belongs_to :location, :inverse_of => :business_hour_exceptions


  ## Validations ##

  validates_presence_of :location
  validates :closed_at, :presence => true
  validates :closed_at, :uniqueness => { :scope => :location_id }


  ## Mass-assignable attributes ##

  attr_accessible(:location_id, :location, :closed_at)


  ## Instance Methods ##

  def day
    closed_at.strftime('%e')
  end

  def day_sym
    day.downcase.to_sym
  end

  def month
    closed_at.strftime('%-m')
  end

  def to_a
    [month.to_i, day.to_i]
  end

end
