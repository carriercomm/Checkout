class AuditInventoryRecordDecorator < InventoryRecordDecorator

  def type
    h.t('values.inventory_record.type.audit_inventory_record')
  end

end
