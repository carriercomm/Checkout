class BrandDecorator < ApplicationDecorator
  decorates :brand
  decorates_association :component_models
  delegate :name

  def component_count
    return 1
    component_models.reduce(0) {|sum, cm| sum + cm.component_count }
  end

  def to_link
    h.link_to(source.name, h.brand_path(source))
  end

  def to_s
    source.name
  end

end
