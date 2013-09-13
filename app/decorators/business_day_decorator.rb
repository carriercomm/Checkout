class BusinessDayDecorator < ApplicationDecorator

  decorates :business_hour
  decorates_association :business_days
  decorates_association :location

  delegate :index, :name

  def to_s(ref_time = Time.zone.now)
    I18n.t('date.abbr_day_names')[object.index].titleize
  end

end
