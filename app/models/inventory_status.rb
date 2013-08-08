class InventoryStatus < ActiveRecord::Base

  ## Associations ##

  has_many :inventory_details, :inverse_of => :inventory_status


  ## Validations ##

  validates :name, :uniqueness => true


  ## Mass-assignable Attributes ##

  attr_accessible :index, :name


  def self.value_symbols
    all.map(&:id).map(&:to_s).map(&:to_sym)
  end

end
