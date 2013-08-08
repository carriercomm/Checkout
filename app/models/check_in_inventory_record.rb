class CheckInInventoryRecord < InventoryRecord

  belongs_to :loan, :inverse_of => :check_in_inventory_record

end
