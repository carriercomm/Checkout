class CheckOutInventoryRecordDecorator < InventoryRecordDecorator

  def type
    h.t('values.inventory_record.type.check_out_inventory_record')
  end

end
