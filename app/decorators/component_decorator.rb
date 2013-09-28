class ComponentDecorator < ApplicationDecorator
  decorates :component
  decorates_association :budget
  decorates_association :component_model
  decorates_association :kit
  decorates_association :inventory_details

  delegate :asset_tag, :id, :new_record?, :persisted?, :serial_number

  def disposition
    case object.current_inventory_detail.try(:missing)
    when true
      return h.t('values.inventory_detail.missing.true')
    when false
      return h.t('values.inventory_detail.missing.false')
    else
      return h.t('values.inventory_detail.missing.unknown')
    end
  end

  def to_link
    h.link_to("#{ component_model.brand } #{ component_model }", h.component_path(source))
  end

  def to_s
    "#{ component_model.brand } #{ component_model }"
  end

end
