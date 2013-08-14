class InventoryDetail < ActiveRecord::Base

  ## Associations ##

  belongs_to :component,          :inverse_of => :inventory_details
  belongs_to :inventory_record,   :inverse_of => :inventory_details

  ## Callbacks ##

  before_save :populate_kit_in_inventory_record

  ## Validations ##

  validates :component,           :associated => true
  validates :component_id,        :presence   => true
  validates :inventory_record,    :associated => true
  # validates :inventory_record_id, :presence   => true

  ## Mass-assignable attributes ##

  attr_accessible :component, :component_id, :inventory_record, :inventory_record_id, :missing, :created_at

  def populate_kit_in_inventory_record
    if inventory_record && inventory_record.kit.nil? && component && component.kit
      inventory_record.kit = component.kit
    end
  end

end
