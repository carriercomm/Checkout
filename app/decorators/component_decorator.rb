class ComponentDecorator < ApplicationDecorator
  decorates :component
  decorates_association :component_model

  allows :asset_tag, :serial_number, :update_attributes

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
