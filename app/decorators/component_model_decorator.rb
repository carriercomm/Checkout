class ComponentModelDecorator < ApplicationDecorator
  decorates :component_model
  decorates_association :brand
  decorates_association :categories
  decorates_association :components
  decorates_association :kits

  def autocomplete_json
    {
      :label => to_s,
      :value => h.url_for(model)
    }
  end

  def brand_name
    model.brand.to_s
  end

  def category_list
    categories.map(&:to_link).join(", ").html_safe
  end

  def description
    val_or_space(model.description)
  end

  def linked_branded_name
    "#{ linked_brand } #{ linked_name }".html_safe
  end

  # TODO: delegate this to a BrandDecorator?
  def linked_brand
    h.link_to(brand_name, h.brand_path(model.brand))
  end

  def linked_name
    h.link_to(model.name, h.component_model_path(model))
  end

  def select2_json
    {
      :id   => id,
      :text => to_s
    }
  end

  def training_required
    to_yes_no(model.training_required)
  end

  def to_link
    h.link_to(to_s, h.component_model_path(model))
  end

  def to_s
    "#{ brand_name } #{ model.name }"
  end

end
