class InventoryDetail < ActiveRecord::Base

  ## Associations ##

  belongs_to :component,        :inverse_of => :inventory_details
  belongs_to :inventory_status, :inverse_of => :inventory_details
  belongs_to :inventory_record, :inverse_of => :inventory_details
  # attr_accessible :title, :body
end
