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

  # def closed_on?(date)
  #   return !open_on?(date)
  # end

  # # returns an array of dates for each business_hour_exception
  # # at this location
  # def dates_exception(days_out = 90, date_start = Time.zone.now)
  #   date_end   = date_start + days_out.days

  #   # find any exceptions that fall on or between these days
  #   bhe = business_hour_exceptions
  #     .where("closed_at >= ? AND closed_at <= ?", date_start, date_end)
  #     .all

  #   bhe.map(&:closed_at).uniq
  # end

=begin
  # returns an array of [month, day] pairs for each
  # business_hour_exception at this location
  def dates_exception_for_datepicker(days_out = 90)
    # convert them to an array
    dates_exception(days_out).to_a
  end
=end



  # def dates_regular(days_out = 90, date_start = Time.zone.now)
  #   dates = []
  #   business_hours.each do |x|
  #     occurrences = x.open_occurrences(days_out, date_start)
  #     occurrences.map!(&:to_date)
  #     dates.concat(occurrences)
  #   end
  #   dates.uniq
  # end

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

  def times_open(days_out = 90)
    occurrences = []

    schedules.each do |s|
      # should today be included?
      if s.occurring_between?(Time.zone.now, Time.zone.now.end_of_day)
        end_time = Time.zone.now.at_beginning_of_day + days_out.days
      else
        end_time = Time.zone.now.end_of_day + days_out.days
      end
      occurrences.concat(s.occurrences(end_time))
    end

    occurrences.sort!
    occurrences
  end

  # finds the closest open date on, or after, the time passed
  def next_time_open(time = Time.zone.now)
    nexts = []

    time = time.to_time

    schedules.each do |s|
      # should today be included?
      if s.occurring_between?(time, time.end_of_day)
        ref_time = time.at_beginning_of_day
      else
        ref_time = time
      end
      nexts << s.next_occurrence(ref_time)
    end
    nexts.sort.first.to_time
  end

  def open_on?(date)
    schedules.each do |s|
      return true if s.occurs_on?(date.to_time.at_beginning_of_day)
    end
    return false
  end

  def schedules
    schedules  = []
    exceptions = {}

    # gather up the exceptions by day of the week
    business_hour_exceptions.each do |bhe|
      day = bhe.closed_at.strftime('%A')
      exceptions[day] = [] unless exceptions[day]
      exceptions[day] << bhe.closed_at.to_time.at_beginning_of_day
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

  def to_param
    "#{ id } #{ name }".parameterize
  end

  def to_s
    name
  end

end
