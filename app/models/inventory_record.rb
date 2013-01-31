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


  scope :current, joins(<<-END_SQL
    INNER JOIN (SELECT component_id, MAX(created_at) AS max_created_at
     FROM inventory_records
     GROUP BY component_id) ir2 ON inventory_records.component_id = ir2.component_id AND inventory_records.created_at = ir2.max_created_at
    END_SQL
  )

  scope :currently_missing, current.where(:inventory_status_id => 3)

end
