class InventoryDetail < ActiveRecord::Base
  class MismatchedKitException < Exception; end

  ## Associations ##

  belongs_to :component,          :inverse_of => :inventory_details
  belongs_to :inventory_record,   :inverse_of => :inventory_details

  ## Validations ##

  validates :component,           :presence  => true
  validates :inventory_record,    :presence  => true
  validates :missing,             :inclusion => { :in => [true, false], :message => "must be marked as present or missing" }
  # validates :component,           :associated => true
  # validates :inventory_record,    :associated => true

  ## Mass-assignable attributes ##

  attr_accessible :component, :component_id, :inventory_record, :inventory_record_id, :missing, :created_at

end
