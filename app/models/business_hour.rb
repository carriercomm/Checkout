class BusinessHour < ActiveRecord::Base

  include IceCube

  def self.days_for_select
    IceCube::TimeUtil::DAYS.collect {|k,v| [k.to_s.titleize, k] }
  end

  def schedule
    new_schedule = Schedule.new(Date.today)
    new_schedule.add_recurrence_date(Time.now)
    new_schedule.add_exception_date(Time.now + 1)
    return new_schedule
  end

end
