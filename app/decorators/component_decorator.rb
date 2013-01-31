class ComponentDecorator < ApplicationDecorator
  decorates :component
  decorates_association :component_model
  decorates_association :kit
  decorates_association :inventory_records

  delegate :asset_tag, :id, :serial_number

  def current_status
    ir = source.latest_inventory_record

    if !!ir
      ir.decorate.inventory_status.name
    else
      h.t('inventory_status.unknown')
    end
  end

  def missing
    to_yes_no(source.missing)
  end

  def to_link
    h.link_to("#{ component_model.brand } #{ component_model }", h.component_path(source))
  end

  def to_s
    "#{ component_model.brand } #{ component_model }"
  end

end
