class BrandDecorator < Draper::Base
  decorates :brand
  decorates_association :componet_models

  def to_link
    h.link_to(model.name, h.brand_path(model))
  end
end
