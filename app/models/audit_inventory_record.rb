class AuditInventoryRecord < InventoryRecord

  # TODO: this is a hack, revisit how best to handle this case in index views
  def loan
    nil
  end

end
