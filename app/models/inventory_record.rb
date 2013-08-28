class InventoryRecord < ActiveRecord::Base
  class MismatchingKitException    < Exception; end
  class AbstractBaseClassException < Exception; end

  ## Associations ##

  belongs_to :attendant,         :inverse_of => :inventory_records, :class_name => "User"
  has_many   :inventory_details, :inverse_of => :inventory_record,  :dependent  => :destroy
  has_many   :components,        :through    => :inventory_details, :before_add => [:reconcile_component_with_kit]
  belongs_to :kit,               :inverse_of => :inventory_records
  belongs_to :loan,              :inverse_of => :inventory_records

  accepts_nested_attributes_for :inventory_details, :reject_if => proc { |attributes| attributes['component_id'].blank? }, :allow_destroy=> true

  ## Validations ##

  validates :attendant, :presence => true
  validates :kit,       :presence => true
  validates :type,      :presence => true
  validate  :validate_attendant_has_proper_roles

  ## Mass-assignable Attributes ##

  attr_accessible :attendant, :attendant_id, :kit, :kit_id, :loan, :loan_id

  # scope :current, joins(<<-END_SQL
  #   INNER JOIN (SELECT component_id, MAX(created_at) AS max_created_at
  #    FROM inventory_records
  #    GROUP BY component_id) ir2 ON inventory_records.component_id = ir2.component_id AND inventory_records.created_at = ir2.max_created_at
  #   END_SQL
  # )

  # this is effetively an abstract base, so don't use it directly
  def initialize(args=nil)
    if self.class == InventoryRecord
      raise AbstractBaseClassException.new("Cannot directly instantiate an InventoryRecord, use AuditInventoryRecord, CheckInInventoryRecord or CheckOutInventoryRecord instead")
    end
    super
  end

  def autofill_kit
    return if kit || components.empty?
    kits = components.map {|c| c.kit }
    kit  = kits.uniq
  end

  def initialize_inventory_details(missing = nil)
    raise "kit cannot be nil" if kit.nil?
    kit.components.map do |c|
      inventory_details.build(component: c, missing: missing)
    end
  end

  private

  def reconcile_component_with_kit(component)
    if kit.nil?
      self.kit = component.kit
    else
      unless kit == component.kit
        raise MismatchingKitException.new("Can't add a component with a mismatching kit")
      end
    end
  end

  def validate_attendant_has_proper_roles
    unless attendant.attendant?
      errors[:base] << "Inventory attendant must have the role of 'attendant'"
    end
  end

end
