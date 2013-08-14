class CheckInInventoryRecordDecorator < InventoryRecordDecorator

  def type
    h.t('inventory_record.type.check_in')
  end

end
