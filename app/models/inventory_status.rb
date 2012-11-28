class InventoryStatus < ActiveRecord::Base

  ## Macros ##

  rolify


  ## Associations ##

  has_many :inventory_records, :inverse_of => :inventory_status


  ## Mass-assignable Attributes ##

  attr_accessible :name

end
