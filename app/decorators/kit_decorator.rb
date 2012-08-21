class KitDecorator < ApplicationDecorator
  decorates :kit

  allows(:budget_id,
         :checkoutable?,
         :location_id,
         :primary_component,
         :reservable?,
         :to_key)

  def asset_tags
    model.asset_tags.map(&:to_s).join(", ")
  end

  def autocomplete_json(options={})
    q     = options.delete(:q)
    raise self.inspect if q.nil?
    regexp = Regexp.quote(q)
    at    = asset_tags.select {|at| /#{regexp}/ =~ at }
    label = "[#{ at.join(",
  ") }] #{ branded_components_description }".squish

    {
      :label => label,
      :value => h.url_for(model)
    }
  end

  def branded_components
    branded_names = component_models.map { |cm| ModelDecorator.decorate(cm).to_s }
    branded_names.join(", ").html_safe
  end

  def linked_branded_components
    branded_names = component_models.map { |cm| ModelDecorator.decorate(cm).to_s }
    branded_names.join(", ").html_safe
  end

  def budget
    BudgetDecorator.decorate(model.budget).try(:to_s).try(:html_safe)
  end

  def checkoutable
    to_yes_no(model.checkoutable)
  end

  def components
    ComponentDecorator.decorate(model.components)
  end

  # returns a string of comma delimited model names
  def components_description
    component_models.map(&:to_s).join(", ")
  end

  def cost
    h.number_to_currency(model.cost)
  end

  def insured
    to_yes_no(model.insured)
  end

  def location
    val_or_space(model.location)
  end

  def tombstoned
    to_yes_no(model.tombstoned)
  end

  def training_required
    to_yes_no(model.training_required?)
  end

  private

  def component_models
    model.components.order("components.position ASC").collect { |c| c.model }
  end

end
