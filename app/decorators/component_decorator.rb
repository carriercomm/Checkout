class ComponentDecorator < ApplicationDecorator
  decorates :component
  decorates_association :component_model
  decorates_association :kit
  decorates_association :inventory_records

  allows :asset_tag, :serial_number, :update_attributes

  def current_status
    ir = model.latest_inventory_record

    if !!ir
      InventoryRecordDecorator.decorate(ir).inventory_status.name
    else
      h.t('inventory_status.unknown')
    end
  end

  def missing
    to_yes_no(model.missing)
  end

  def to_link
    h.link_to("#{ component_model.brand } #{ component_model }", h.component_path(model))
  end

  def to_s
    "#{ component_model.brand } #{ component_model }"
  end

end
