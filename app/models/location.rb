class Location < ActiveRecord::Base

  #
  # Associations
  #

  # TODO: enforce some referential integrity so you can't delete a location and orphan all its kits
  has_many :business_hours,           :inverse_of => :location
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

  attr_accessible :name


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

  # returns the first opening time for the given date
  def first_opening_time_on_date(date)
    # return nothing if we're closed on this day
    if !business_hour_exceptions.where("date_closed = ?", date.to_date).empty?
      return nil
    end

    # convert the date to a day of the week
    day_of_week = day_of_week(date)

    # get the first set of business hours on this day
    return business_hours.where(:open_day => day_of_week).order("business_hours.open_day ASC").first
  end

  # returns the last closing time for the given date
  def last_closing_time_on_date(date)
    # return nothing if we're closed on this day
    if !business_hour_exceptions.where("date_closed = ?", date.to_date).empty?
      return nil
    end

    # convert the date to a day of the week
    day_of_week = day_of_week(date)

    # get the last set of business hours on this day
    return business_hours.where(:open_day => day_of_week).order("business_hours.open_day DESC").first
  end

  def open_on?(date)
    return !first_opening_time_on_date(date).nil?
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

  private

  def day_of_week(date)
    wday = nil

    if date.kind_of? DateTime
      wday = date.to_time.wday
    elsif ((date.kind_of? Time) || (date.kind_of? Date))
      wday = date.wday
    else
      raise "Expected an instance of Time, Date, or DateTime"
    end

    return Date::DAYNAMES[wday].downcase
  end

end
