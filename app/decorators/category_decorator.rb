class CategoryDecorator < Draper::Base
  decorates :category

  def to_link
    h.link_to(model.name, h.category_path(model))
  end

  def to_s
    model.name
  end

end
