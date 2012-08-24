class ComponentDecorator < ApplicationDecorator
  decorates :component

  allows :asset_tag, :serial_number

  def linked_brand
    ComponentModelDecorator.decorate(model.component_model).linked_brand
  end

  def linked_model
    ComponentModelDecorator.decorate(model.component_model).linked_name
  end

  def missing
    to_yes_no(model.missing)
  end

end
