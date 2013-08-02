class LocationDecorator < ApplicationDecorator

  decorates :location
  decorates_association :business_hours
  decorates_association :business_hour_exceptions
  decorates_association :kits

  delegate :to_s

end
