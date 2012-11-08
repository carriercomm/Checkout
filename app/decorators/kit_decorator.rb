class KitDecorator < ApplicationDecorator
  decorates :kit
  decorates_association :budget
  decorates_association :component_models
  decorates_association :components
  decorates_association :groups
  decorates_association :loans

  allows(:budget_id,
         :checkoutable?,
         :location_id,
         :primary_component,
         :reservable?,
         :to_key)

  def asset_tags
    text = model.asset_tags.map(&:to_s).join(", ")
    h.content_tag("span", title: text) do
      text
    end
  end

  def autocomplete_json(options={})
    q     = options.delete(:q)
    raise self.inspect if q.nil?
    regexp = Regexp.quote(q)
    at    = model.asset_tags.select {|at| /#{regexp}/ =~ at }
    label = "[#{ at.join(", ") }] #{ component_list }".squish

    {
      :label => label,
      :value => h.url_for(model)
    }
  end

  def checkoutable
    to_yes_no(model.checkoutable)
  end

  # returns a string of comma delimited model names
  def component_list
    text = component_models.map(&:to_s).join(", ")
    h.content_tag("span", title: text) do
      text
    end
  end

  def cost
    h.number_to_currency(model.cost)
  end

  def description
    "[#{ asset_tags }] #{ component_list }".squish
  end

  def id
    h.link_to(model.id, h.kit_path(model))
  end

  def linked_groups_list
    groups.map(&:to_link).join(", ").html_safe
  end

  def insured
    to_yes_no(model.insured)
  end

  def linked_component_list
    component_models.map(&:to_link).join(", ").html_safe
  end

  def location
    coalesce(model.location)
  end

  def raw_id
    model.id
  end

  def select2_json
    {
      :id   => model.id,
      :text => description
    }
  end

  def status
    (model.checked_out?) ? h.t('kit.status.checked_out') : h.t('kit.status.available')
  end

  def to_s
    h.link_to(model.id, h.kit_path(model))
  end

  def tombstoned
    to_yes_no(model.tombstoned)
  end

  def training_required
    to_yes_no(model.training_required?)
  end

end
