class ComponentModelDecorator < ApplicationDecorator
  decorates :component_model
  decorates_association :brand
  decorates_association :categories
  decorates_association :components
  decorates_association :kits
  decorates_association :trainings
  decorates_association :users

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
    list = categories.map(&:to_link).join(", ")
    coalesce(list)
  end

  def component_count
    model.components.count
  end

  def description
    coalesce(model.description)
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

  def to_branded_s
    "#{ brand_name } #{ model.name }"
  end

  def to_s
    model.name
  end

end
