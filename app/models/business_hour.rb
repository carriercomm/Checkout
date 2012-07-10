class BusinessHour < ActiveRecord::Base

  belongs_to :location

  # TODO: validate with overlap detection for business hours

  validates :location_id,  :presence => true
  validates :open_day,     :presence => true
  validates :open_day,     :inclusion    => { :in => %w(monday tuesday wednesday thursday friday saturday sunday),
                                              :message => "should be a valid day of the week" }
  validates :open_hour,    :presence => true
  validates :open_hour,    :numericality => { :only_integer => true,
                                              :greater_than_or_equal_to => 0,
                                              :less_than => 24 }
  validates :open_minute,  :presence => true
  validates :open_minute,  :numericality => { :only_integer => true,
                                              :greater_than_or_equal_to => 0,
                                              :less_than => 60 }
  validates :close_day,    :presence => true
  validates :close_day,    :inclusion    => { :in => %w(monday tuesday wednesday thursday friday saturday sunday),
                                              :message => "should be a valid day of the week" }
  validates :close_hour,   :presence => true
  validates :close_hour,   :numericality => { :only_integer => true,
                                              :greater_than_or_equal_to => 0,
                                              :less_than => 24 }
  validates :close_minute, :presence => true  
  validates :close_minute, :numericality => { :only_integer => true,
                                              :greater_than_or_equal_to => 0,
                                              :less_than => 60 }
  validate  :validate_hours_in_order, :unless => Proc.new { |rec| rec.required_attrs_blank? }

  attr_accessible(:location_id,
                  :open_day,    
                  :open_hour,   
                  :open_minute, 
                  :close_day,  
                  :close_hour, 
                  :close_minute)

  def self.days_for_select
    IceCube::TimeUtil::DAYS.collect {|k,v| [k.to_s.titleize, k.to_s] }
  end

  def self.hours_for_select
    (0..23).collect { |i| ["%02d" % i, i]}
  end

  def self.minutes_for_select
    [0, 15, 30, 45].collect { |i| ["%02d" % i, i] }
  end

  def self.times_for_select
    times = ["am", "pm"].collect do |meridiem|
      [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].collect do |hour|
        ["00", "15", "30", "45"].collect do |minute|
          ["#{hour}:#{minute}#{meridiem}"]
        end
      end
    end
    times.flatten!
  end

  def validate_hours_in_order
    unless hours_in_order?
      errors[:base] << "Open time must come before close time"
    end
  end

  # converts the open and close times to dates to compare
  def hours_in_order?
    base_time = Time.zone.now
    utc_offset = base_time.to_datetime.offset

    year = base_time.year
    week = base_time.strftime("%U").to_i

    # lots of things will make this blow up (e.g. malformed hours)
    begin
      oday = Date::DAYS_INTO_WEEK[open_day.strip.downcase.to_sym] + 1
      cday = Date::DAYS_INTO_WEEK[close_day.strip.downcase.to_sym] + 1

      open_date  = DateTime.commercial(year, week, oday, open_hour, open_minute, 0, utc_offset)
      close_date = DateTime.commercial(year, week, cday, close_hour, close_minute, 0, utc_offset)
    rescue
      return false
    end

    open_date < close_date
  end

  def open_time_s
    return time_to_s(open_hour, open_minute)
  end

  def close_time_s
    return time_to_s(close_hour, close_minute)
  end

  def to_s
    "#{ open_day.titleize } #{ open_time_s }-#{ close_time_s }"
  end

  # returns an array of [month, day] tuples representing the days with
  # open business hours between now and days_out
  def open_occurrences(days_out = 90)
    date_start = Time.zone.now
    date_end   = date_start + days_out.days 
    schedule =  IceCube::Schedule.new

    schedule.add_recurrence_rule IceCube::Rule.weekly.day(open_day.downcase.to_sym)

    occurrences = schedule.occurrences_between(date_start, date_end)
    open_days   = occurrences.collect { |d| [d.month, d.day]}

    return open_days
  end

  def required_attrs_blank?
    return (open_day.blank? || open_hour.blank? || open_minute.blank? ||
            close_day.blank? || close_hour.blank? || close_minute.blank?)
  end

  private

  def time_to_s(hour, minute)
    h = String.new
    m = minute.to_s
    meridiem = "am"

    if hour == 0
      h = 12.to_s
    elsif hour == 12
      h = hour.to_s
      meridiem = "pm"
    elsif hour < 12
      h = hour.to_s
    else
      h = (hour % 12).to_s
      meridiem = "pm"
    end

    return "#{ h }:#{ m }#{ meridiem }"

  end

end
 
