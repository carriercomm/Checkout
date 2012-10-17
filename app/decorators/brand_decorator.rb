class BrandDecorator < Draper::Base
  decorates :brand
  decorates_association :component_models

  def component_count
    return 1
    component_models.reduce(0) {|sum, cm| sum + cm.component_count }
  end

  def to_link
    h.link_to(model.name, h.brand_path(model))
  end

end
