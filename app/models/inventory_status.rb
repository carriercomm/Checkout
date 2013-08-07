class InventoryStatus < ActiveRecord::Base

  ## Macros ##

  rolify


  ## Associations ##

  has_many :inventory_records, :inverse_of => :inventory_status


  ## Validations ##

  validates :name, :uniqueness => true


  ## Mass-assignable Attributes ##

  attr_accessible :index, :name


  def self.value_symbols
    all.map(&:id).map(&:to_s).map(&:to_sym)
  end

end
