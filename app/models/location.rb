class Location < ActiveRecord::Base

  has_many :kits
  has_many :business_hours
  has_many :business_hour_exceptions

  validates :name, :uniqueness => true

  accepts_nested_attributes_for :business_hours, :reject_if => :all_blank, :allow_destroy=> true

  # TODO: enforce some referential integrity so you can't delete a location and orphan all its kits

  # returns the last closing time for the given date
  def closes_at(date)
    # return nothing if we're closed on this day
    if !business_hour_exceptions.where("date_closed = ?", date.to_date).empty?
      return nil
    end

    # figure out our target day of the week
    day_offset = date.days_to_week_start

    hours_on_day = Array.new
    business_hours.each do |bh|
      if bh.closed_at.days_to_week_start == day_offset
        hours_on_day << bh
      end
    end

    return nil if hours_on_day.empty?

    # sort them
    hours_on_day.sort_by! { |x| x.closed_at }
    
    # construct a new datetime with the right hours on the day of inquiry
    # FIXME: I'm sure this calculation of base_datetime is buggy in some time zone
    base_datetime = (date.to_datetime + 1.day).in_time_zone.at_beginning_of_day
    hour_offset   = hours_on_day.first.closed_hour.hours
    minute_offset = hours_on_day.first.closed_minute.minutes
    
    return base_datetime + hour_offset + minute_offset
  end

  # returns an array of [month, day] pairs for each
  # business_hour_exception at this location
  def exception_days(days_out = 90)
    dates = business_hour_exceptions.where("date_closed > ? AND date_closed < ?", Time.now.to_date, Time.now.to_date + days_out.days)
    dates.collect { |d| d.to_a }
  end

  # returns the first opening time for the given date
  def opens_at(date)
    # return nothing if we're closed on this day
    if !business_hour_exceptions.where("date_closed = ?", date.to_date).empty?
      return nil
    end

    # figure out our target day of the week
    day_offset = date.days_to_week_start

    hours_on_day = Array.new
    business_hours.each do |bh|
      if bh.open_at.days_to_week_start == day_offset
        hours_on_day << bh
      end
    end

    return nil if hours_on_day.empty?

    # sort them
    hours_on_day.sort_by! { |x| x.open_at }
    
    # construct a new datetime with the right hours on the day of inquiry
    # FIXME: I'm sure this calculation of base_datetime is buggy in some time zone
    base_datetime = (date.to_datetime + 1.day).in_time_zone.at_beginning_of_day
    hour_offset   = hours_on_day.first.open_hour.hours
    minute_offset = hours_on_day.first.open_minute.minutes
    
    return base_datetime + hour_offset + minute_offset
  end

  def closed_on?(date)
    return !open_on?(date)
  end

  def open_on?(date)
    return opens_at(date) ? true : false
  end

  def open_days(days_out = 90)
    days = []
    business_hours.each { |x| days.concat(x.open_occurrences(days_out)) }
    return days - exception_days
  end

  def to_s
    name
  end

end
