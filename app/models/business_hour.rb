class BusinessHour < ActiveRecord::Base

  belongs_to :location

  # TODO: validate correct ordering of hours
  # TODO: validate with overlap detection for business hours

  # validates :day, :uniqueness => {
  #   :scope => [:location_id, :day_index],
  #   :message => "should happen once per year"
  # }

  validates :day,       :presence => true
  validates :open,      :presence => true
  validates :close,     :presence => true

  # TODO: cleanup this cruft?
  # validate :day_must_map_to_day_index

  # def day_must_map_to_day_index
  #   return if day.blank?
  #   if IceCube::TimeUtil::DAYS[day] != day_index
  #     errors.add(:day, "must match day_index")
  #   end
  # end

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

  def open_occurrences(days_out = 90)
    schedule =  IceCube::Schedule.new
    schedule.add_recurrence_rule IceCube::Rule.weekly.day(self.day.to_sym)
    open_days = schedule.occurrences_between(Time.now, (Time.now + days_out.days)).collect { |d| [d.month, d.day]}
    return open_days
  end


end
