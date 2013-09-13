class BusinessHourDecorator < ApplicationDecorator

  decorates :business_hour
  decorates_association :business_days
  decorates_association :location

  def to_s(ref_time = Time.zone.now)
    "#{ localized_abbr_business_days } #{ localized_hours(ref_time) }"
  end

  private

  def localized_hours(ref_time = Time.zone.now)
    "#{ localized_open_time(ref_time) }-#{ localized_close_time(ref_time) }"
  end

  def localized_abbr_business_days
    business_days.map(&:to_s).join(", ")
  end

  def localized_close_time(ref_time = Time.zone.now)
    time = ref_time.at_beginning_of_day + object.close_hour.hours + object.close_minute.minutes
    return I18n.l(time, :format => :business_hour).strip
  end

  def localized_open_time(ref_time = Time.zone.now)
    time = ref_time.at_beginning_of_day + object.open_hour.hours + object.open_minute.minutes
    return I18n.l(time, :format => :business_hour).strip
  end

end
