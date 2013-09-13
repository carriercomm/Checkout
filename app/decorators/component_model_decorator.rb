class ComponentModelDecorator < ApplicationDecorator
  decorates :component_model
  decorates_association :brand
  decorates_association :categories
  decorates_association :components
  decorates_association :kits
  decorates_association :trainings
  decorates_association :users

  delegate :id, :name, :model_number, :circulating?, :reservable?

  def autocomplete_json
    {
      :label => to_s,
      :value => h.url_for(source),
      :category => h.t("component_model.index.title").html_safe
    }
  end

  def brand_name
    source.brand.to_s
  end

  def category_list
    list = categories.map(&:to_link).join(", ")
    coalesce(list)
  end

  def component_count
    source.components.count
  end

  def description
    coalesce(source.description)
  end

  def select2_json
    {
      :id   => id,
      :text => to_s
    }
  end

  def training_required
    to_yes_no(source.training_required)
  end

  def to_link
    h.link_to(to_s, h.component_model_path(source))
  end

  def to_branded_s
    "#{ brand_name } #{ source.name }"
  end

  def to_s
    to_branded_s
  end

end
