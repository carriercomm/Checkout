class InventoryDetail < ActiveRecord::Base

  ## Associations ##

  belongs_to :component,        :inverse_of => :inventory_details
  belongs_to :inventory_record, :inverse_of => :inventory_details

  ## Mass-assignable attributes ##

  attr_accessible :component, :inventory_record, :missing

end
