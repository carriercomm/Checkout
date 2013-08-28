class KitDecorator < ApplicationDecorator
  decorates :kit
  decorates_association :budget
  decorates_association :component_models
  decorates_association :components
  decorates_association :groups
  decorates_association :loans

  delegate(:budget_id,
           :circulating?,
           :count,
           :id,
           :location_id,
           :primary_component,
           :reservable?,
           :to_key)

  def asset_tags
    @asset_tags ||= source.asset_tags.map(&:to_s).join(", ")
  end

  def autocomplete_json
    {
      :label => to_autocomplete_s,
      :value => h.url_for(source),
      :category => h.t("kit.index.title").html_safe
    }
  end

  # def kit_jump_autocomplete_json
  #   {
  #     :label => to_autocomplete_s,
  #     :value => h.url_for(source),
  #     :category => h.t("kit.index.title").html_safe
  #   }
  # end

  def circulating
    to_yes_no(source.circulating)
  end

  # returns a string of comma delimited model names
  def component_list
    text = component_models.map(&:to_branded_s).join(", ")
    h.content_tag("span", title: text) do
      text
    end
  end

  def cost
    coalesce(h.number_to_currency(source.cost))
  end

  def description
    "[#{ asset_tags }] #{ component_list }".squish.html_safe
  end

  def linked_groups_list
    groups.map(&:to_link).join(", ").html_safe
  end

  def insured
    to_yes_no(source.insured)
  end

  def linked_component_list
    h.content_tag(:span, title: component_models.map(&:to_s).join(", ")) do
      component_models.map(&:to_link).join(", ").html_safe
    end
  end

  def location
    coalesce(source.location)
  end

  def select2_json
    {
      :id   => source.id,
      :text => to_select2_s
    }
  end

  def status
    (source.checked_out?) ? h.t('kit.status.checked_out') : h.t('kit.status.available')
  end

  def tabular_asset_tags
    h.content_tag("div", title: asset_tags) do
      asset_tags
    end
  end

  def tabular_component_list
    text = component_models.map(&:to_s).join(", ")
    h.content_tag("div", title: text) do
      text
    end
  end

  def to_autocomplete_s
    @autocomplete_s ||= "#{ source.id } | #{ asset_tags } | #{ source.components.map(&:component_model).map(&:to_branded_s).join(", ") }".squish
  end

  def to_link
    text = component_models.map(&:to_branded_s).join(", ")
    title = "[#{ asset_tags }] #{ text }".squish
    h.link_to(source.id, h.kit_path(source), rel: "tooltip", title: title)
  end

  def to_select2_s
    to_autocomplete_s
  end

  def to_s
    to_link
  end

  def tombstoned
    to_yes_no(source.tombstoned)
  end

  def training_required
    to_yes_no(source.training_required?)
  end

end
