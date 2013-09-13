class LocationDecorator < ApplicationDecorator

  decorates :location
  decorates_association :business_hours
  decorates_association :business_hour_exceptions
  decorates_association :kits

  delegate :name, :to_s

  def hours
    h = business_hours.collect { |bh| bh.to_s }
    h.join("<br>").html_safe
  end

  def to_link
    h.link_to(to_s, h.location_path(object))
  end

end
