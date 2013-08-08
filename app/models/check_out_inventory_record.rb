class CheckOutInventoryRecord < InventoryRecord

  belongs_to :loan, :inverse_of => :check_out_inventory_record

end
