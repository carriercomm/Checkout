class InventoryRecordDecorator < ApplicationDecorator
  decorates :inventory_record
  decorates_association :attendant, with: UserDecorator
  decorates_association :components
  decorates_association :inventory_details
  decorates_association :kit
  decorates_association :loan

  delegate :id, :type

  def created_at
    h.l(object.created_at, :format => :tabular)
  end

  def to_s
    id.to_s
  end

end
