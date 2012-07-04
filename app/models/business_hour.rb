class BusinessHour < ActiveRecord::Base

  belongs_to :location

  # TODO: validate with overlap detection for business hours

  # validates :day, :uniqueness => {
  #   :scope => [:location_id, :day_index],
  #   :message => "should happen once per year"
  # }

  validates :open_at,   :presence => true
  validates :closed_at, :presence => true

  validate :validate_hours_in_order

  # TODO: cleanup this cruft?
  # validate :day_must_map_to_day_index

  # def day_must_map_to_day_index
  #   return if day.blank?
  #   if IceCube::TimeUtil::DAYS[day] != day_index
  #     errors.add(:day, "must match day_index")
  #   end
  # end

  attr_accessible :location_id, :open_at, :closed_at

  def self.days_for_select
    IceCube::TimeUtil::DAYS.collect {|k,v| [k.to_s.titleize, k] }
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
      errors.add(:open_at, "must come before close")
      errors.add(:closed_at, "must come after open")
    end
  end

  def hours_in_order?
    open_at < closed_at
  end

  def day
    open_at.try(:strftime, '%A')
  end

  def day_sym
    day.downcase.to_sym
  end

  def open_hour
    open_at.strftime('%k').to_i
  end

  def open_minute
    open_at.strftime('%M').to_i
  end

  def open_at_to_s
    open_at.try(:strftime, '%l:%M%P').try(:strip)
  end

  def closed_at_to_s
    closed_at.try(:strftime, '%l:%M%P').try(:strip)
  end

  def closed_hour
    closed_at.strftime('%k').to_i
  end

  def closed_minute
    closed_at.strftime('%M').to_i
  end

  def to_s
    "#{ day } #{ open_at_to_s }-#{ closed_at_to_s }"
  end

  def open_occurrences(days_out = 90)
    schedule =  IceCube::Schedule.new
    schedule.add_recurrence_rule IceCube::Rule.weekly.day(day_sym)
    open_days = schedule.occurrences_between(Time.now, (Time.now + days_out.days)).collect { |d| [d.month, d.day]}
    return open_days
  end

end
