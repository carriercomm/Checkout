class InventoryRecord < ActiveRecord::Base

  ## Macros ##

  rolify


  ## Associations ##

  belongs_to :attendant,        :inverse_of => :inventory_records, :class_name => "User"
  belongs_to :component,        :inverse_of => :inventory_records
  belongs_to :inventory_status, :inverse_of => :inventory_records

  ## Validations ##

  validates :attendant_id,        :presence   => true
  #validates :attendant,           :associated => true
  validates :component_id,        :presence   => true
  #validates :component,           :associated => true
  validates :inventory_status_id, :presence   => true
  validate  :validate_attendant_has_proper_roles


  ## Mass-assignable Attributes ##

  attr_accessible :attendant, :attendant_id, :component, :component_id, :inventory_status, :inventory_status_id, :loan, :loan_id


  scope :current, joins(<<-END_SQL
    INNER JOIN (SELECT component_id, MAX(created_at) AS max_created_at
     FROM inventory_records
     GROUP BY component_id) ir2 ON inventory_records.component_id = ir2.component_id AND inventory_records.created_at = ir2.max_created_at
    END_SQL
  )

  scope :currently_missing, current.where(:inventory_status_id => 3)


  def validate_attendant_has_proper_roles
    unless attendant.attendant?
      errors[:base] << "Inventory attendant must have the role of 'attendant'"
    end
  end


end
