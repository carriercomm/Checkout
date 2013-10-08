class CheckInInventoryRecordDecorator < InventoryRecordDecorator

  def type
    h.t('values.inventory_record.type.check_in_inventory_record')
  end

end
