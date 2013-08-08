class InventoryRecord < ActiveRecord::Base

  ## Associations ##

  belongs_to :attendant,         :inverse_of => :inventory_records, :class_name => "User"
  has_many   :inventory_details, :inverse_of => :inventory_record
  has_many   :components,        :through    => :inventory_details
  belongs_to :kit,               :inverse_of => :inventory_records
  belongs_to :loan,              :inverse_of => :inventory_records

  ## Validations ##

  validates :attendant_id, :presence => true
  validates :type,         :presence => true
  validate  :validate_attendant_has_proper_roles


  ## Mass-assignable Attributes ##

  attr_accessible :attendant, :attendant_id, :kit, :kit_id, :loan, :loan_id


  # scope :current, joins(<<-END_SQL
  #   INNER JOIN (SELECT component_id, MAX(created_at) AS max_created_at
  #    FROM inventory_records
  #    GROUP BY component_id) ir2 ON inventory_records.component_id = ir2.component_id AND inventory_records.created_at = ir2.max_created_at
  #   END_SQL
  # )

  # scope :currently_missing, current.where(:inventory_status_id => 3)

  def initialize_inventory_details(inventory_status = nil)
    raise "kit cannot be nil" if kit.nil?
    kit.components.map do |c|
      inventory_details.build(component: c, inventory_status: inventory_status)
    end
  end

  def validate_attendant_has_proper_roles
    unless attendant.attendant?
      errors[:base] << "Inventory attendant must have the role of 'attendant'"
    end
  end

end
