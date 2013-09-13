class Location < ActiveRecord::Base
  class InvalidTimeFormatException < Exception; end

  ## Macros ##

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

  # def closed_on?(date)
  #   return !open_on?(date)
  # end

  # # returns an array of dates for each business_hour_exception
  # # at this location
  # def dates_exception(days_out = 90, date_start = DateTime.current)
  #   date_end   = date_start + days_out.days

  #   # find any exceptions that fall on or between these days
  #   bhe = business_hour_exceptions
  #     .where("closed_at >= ? AND closed_at <= ?", date_start, date_end)
  #     .all

  #   bhe.map(&:closed_at).uniq
  # end

  # # returns an array of [month, day] pairs for each
  # # business_hour_exception at this location
  # def dates_exception_for_datepicker(days_out = 90)
  #   # convert them to an array
  #   dates_exception(days_out).to_a
  # end




  # def dates_regular(days_out = 90, date_start = DateTime.current)
  #   dates = []
  #   business_hours.each do |x|
  #     occurrences = x.open_occurrences(days_out, date_start)
  #     occurrences.map!(&:to_date)
  #     dates.concat(occurrences)
  #   end
  #   dates.uniq
  # end

  # def hours_on(date)
  #   # return nothing if we're closed on this day
  #   if !business_hour_exceptions.where("closed_at = ?", date.to_date).empty?
  #     return []
  #   end

  #   day   = date.wday
  #   hours = business_hours.joins(:business_days).where("business_days.index = ?", day).order("business_hours.open_hour ASC")

  #   return hours.all
  # end

  def datetimes_open(days_out = 90)
    occurrences = []

    schedules.each do |s|
      # should today be included?
      end_time = if s.occurring_between?(Time.zone.now, Time.zone.now.end_of_day)
                   Time.zone.now.at_beginning_of_day + days_out.days
                 else
                   Time.zone.now.end_of_day + days_out.days
                 end

      occurrences.concat(s.occurrences(end_time))
    end

    occurrences.sort.map(&:to_datetime)
  end

  # finds the closest open date on, or after, the time passed
  def next_datetime_open(datetime = DateTime.current)
    return nil unless business_hours.count > 0
    nexts = []
    time  = convert_to_time(datetime)

    schedules.each do |s|
      # should today be included?
      if s.occurring_between?(time, time.end_of_day)
        ref_time = time.at_beginning_of_day
      else
        ref_time = time
      end
      nexts << s.next_occurrence(ref_time)
    end
    return nil if nexts.empty?
    nexts.sort.first.to_datetime
  end

  # returns true if the location has any hours on the same day as 'time'
  def open_on?(datetime)
    time = convert_to_time(datetime)

    schedules.each do |s|
      return true if s.occurs_on?(time.at_beginning_of_day)
    end
    return false
  end

  def to_param
    "#{ id } #{ name }".parameterize
  end

  def to_s
    name
  end

  private

  def convert_to_time(thing)
    if thing.kind_of? Date
      return Time.local(thing.year, thing.month, thing.day)
    elsif thing.kind_of? DateTime
      return Time.local(thing.year, thing.month, thing.day, thing.hour, thing.min, thing.sec)
    elsif thing.is_a? Time
      return thing
    elsif thing.is_a? String
      return Time.zone.parse(thing)
    end

    raise InvalidTimeFormatException.new("Expected a Date, DateTime, Time, or String, got: #{ thing.class }")
  end

  # TODO: refactor this to store the schedule as a serialized hash?
  #       consider what this does to time zone offsets, since the hash
  #       stores the name of the offset instead of getting the offset
  #       from the local computer. Any way to convert to hash without
  #       time zone support?
  def schedules
    schedules  = []
    exceptions = Hash.new { |h,k| h[k] = [] }

    # gather up the exceptions by day of the week
    business_hour_exceptions.each do |bhe|
      day = bhe.closed_at.strftime('%A')
      exceptions[day] << bhe.closed_at.to_time_in_current_zone.at_beginning_of_day
    end

    business_hours.each do |bh|
      start_time = Time.zone.now.at_beginning_of_day + bh.open_hour.hours  + bh.open_minute.minutes
      end_time   = Time.zone.now.at_beginning_of_day + bh.close_hour.hours + bh.close_minute.minutes
      schedule   = IceCube::Schedule.new(start_time, end_time: end_time)

      # add a recurrence for each business day
      bh.business_days.each do |bd|
        day = bd.name.downcase.to_sym
        schedule.add_recurrence_rule IceCube::Rule.weekly.day(day)

        # add any exceptions to the schedule
        if exceptions[bd.name]
          exceptions[bd.name].each do |e|
            exception_time = (e + bh.open_hour.hours + bh.open_minute.minutes)
            schedule.add_exception_time(exception_time)
          end
        end
      end
      schedules << schedule
    end
    return schedules
  end

end
