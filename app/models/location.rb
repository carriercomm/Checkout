class Location < ActiveRecord::Base

  ## Macros ##

  resourcify
  strip_attributes


  ## Associations ##

  # TODO: enforce some referential integrity so you can't delete a location and orphan all its kits
  has_many :business_hours,           :inverse_of => :location, :dependent => :destroy
  has_many :business_hour_exceptions, :inverse_of => :location
  has_many :kits,                     :inverse_of => :location

  accepts_nested_attributes_for :business_hours, :reject_if => :all_blank, :allow_destroy=> true


  ## Validations ##

  validates :name, :uniqueness => {:case_sensitive => false}


  ## Mass-assignable attributes ##

  attr_accessible :name, :business_hours_attributes


  ## Named Scopes ##

  scope :with_business_hours, joins(:business_hours).includes(:business_hours)


  ## Instance Methods ##

  def closed_on?(date)
    return !open_on?(date)
  end

  # returns an array of dates for each business_hour_exception
  # at this location
  def dates_exception(days_out = 90, date_start = Time.zone.now)
    date_end   = date_start + days_out.days

    # find any exceptions that fall on or between these days
    bhe = business_hour_exceptions
      .where("closed_at >= ? AND closed_at <= ?", date_start, date_end)
      .all

    bhe.map(&:closed_at).uniq
  end

=begin
  # returns an array of [month, day] pairs for each
  # business_hour_exception at this location
  def dates_exception_for_datepicker(days_out = 90)
    # convert them to an array
    dates_exception(days_out).to_a
  end
=end

  def dates_open(days_out = 90, date_start = Time.zone.now)
    return dates_regular(days_out, date_start) - dates_exception(days_out, date_start)
  end

  def dates_open_for_datepicker(days_out = 90, date_start = Time.zone.now)
    dates_open(days_out, date_start).collect { |d| [d.month, d.day] }
  end

  def dates_regular(days_out = 90, date_start = Time.zone.now)
    dates = []
    business_hours.each do |x|
      occurrences = x.open_occurrences(days_out, date_start)
      occurrences.map!(&:to_date)
      dates.concat(occurrences)
    end
    dates.uniq
  end

  def hours_on(date)
    # return nothing if we're closed on this day
    if !business_hour_exceptions.where("closed_at = ?", date.to_date).empty?
      return []
    end

    day   = date.wday
    hours = business_hours.joins(:business_days).where("business_days.index = ?", day).order("business_hours.open_hour ASC")

    return hours.all
  end

  def hours_to_s
    business_hours.collect { |bh| bh.to_s }
  end

  # finds the closest open date on, or after, the time passed
  def next_date_open(time = Time.zone.now)
    dates_open(90, time).first
  end

  def open_on?(date)
    return !hours_on(date).empty?
  end

  def to_param
    "#{ id } #{ name }".parameterize
  end

  def to_s
    name
  end

end
