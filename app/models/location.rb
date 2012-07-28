class Location < ActiveRecord::Base

  #
  # Macros
  #
  
  strip_attributes
  

  #
  # Associations
  #

  # TODO: enforce some referential integrity so you can't delete a location and orphan all its kits
  has_many :business_hours,           :inverse_of => :location, :dependent => :destroy
  has_many :business_hour_exceptions, :inverse_of => :location
  has_many :kits,                     :inverse_of => :location

  accepts_nested_attributes_for :business_hours, :reject_if => :all_blank, :allow_destroy=> true


  #
  # Validations
  #

  validates :name, :uniqueness => true


  #
  # Mass-assignable attributes
  #

  attr_accessible :name, :business_hours_attributes


  #
  # Instance Methods
  #

  def closed_on?(date)
    return !open_on?(date)
  end

  # returns an array of [month, day] pairs for each
  # business_hour_exception at this location
  def exception_days(days_out = 90)
    start_date = Time.now.to_date
    end_date   = start_date + days_out.days

    # find any exceptions that fall on or between these days
    dates = business_hour_exceptions.where("date_closed >= ? AND date_closed <= ?", start_date, end_date)

    # convert them to an array
    dates.collect { |d| d.to_a }
  end

  def hours_on(date)
    # return nothing if we're closed on this day
    if !business_hour_exceptions.where("date_closed = ?", date.to_date).empty?
      return []
    end

    day   = date.wday
    hours = business_hours.joins(:business_days).where("business_days.index = ?", day).order("business_hours.open_hour ASC")

    return hours.all
  end

  def hours_to_s
    business_hours.collect { |bh| bh.to_s }
  end

  def open_on?(date)
    return !hours_on(date).empty?
  end

  def open_days(days_out = 90)
    days = []
    business_hours.each { |x| days.concat(x.open_occurrences(days_out)) }
    return days - exception_days
  end

  def to_param
    "#{ id } #{ name }".parameterize
  end

  def to_s
    name
  end
  
end
