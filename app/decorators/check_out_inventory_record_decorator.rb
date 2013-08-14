class CheckOutInventoryRecordDecorator < InventoryRecordDecorator

  def type
    h.t('inventory_record.type.check_out')
  end

end
