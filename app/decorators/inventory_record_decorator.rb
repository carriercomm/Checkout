class InventoryRecordDecorator < ApplicationDecorator
  decorates :inventory_record
  decorates_association :attendant, with: UserDecorator
  decorates_association :components
  decorates_association :inventory_details
  decorates_association :kit
  decorates_association :loan

  def created_at
    h.l(source.created_at, :format => :tabular)
  end

end
