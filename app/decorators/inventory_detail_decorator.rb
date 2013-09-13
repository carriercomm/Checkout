class InventoryDetailDecorator < ApplicationDecorator
  decorates :inventory_detail
  decorates_association :component
  decorates_association :inventory_record

  def created_at
    h.l(source.created_at, :format => :tabular)
  end

  def missing
    to_yes_no(object.missing)
  end

end
