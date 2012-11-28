class InventoryRecord < ActiveRecord::Base

  ## Macros ##

  rolify


  ## Associations ##

  belongs_to :component, :inverse_of => :inventory_records
  belongs_to :loan, :inverse_of => :inventory_records
  belongs_to :attendant, :inverse_of => :inventory_records, :class_name => "User"
  belongs_to :inventory_status, :inverse_of => :inventory_records


  ## Mass-assignable Attributes ##

  # attr_accessible(:attendant_id,
  #                 :component_id,
  #                 :inventory_status_id,
  #                 :loan_id)

end
