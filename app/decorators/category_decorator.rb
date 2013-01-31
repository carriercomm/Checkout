class CategoryDecorator < ApplicationDecorator
  decorates :category
  delegate  :name, :description

  def to_link
    h.link_to(source.name, h.category_path(source))
  end

  def to_s
    source.name
  end

end
