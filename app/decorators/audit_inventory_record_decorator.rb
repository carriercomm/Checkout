class AuditInventoryRecordDecorator < InventoryRecordDecorator

  def type
    h.t('inventory_record.type.audit')
  end

end
