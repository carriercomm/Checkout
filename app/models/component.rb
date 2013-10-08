class Component < ActiveRecord::Base

  ## Macros ##

  acts_as_list :scope => :kit
  strip_attributes


  ## Callbacks ##

  before_create     :autofill_accessioned_at
  before_validation :upcase_serial_number


  ## Associations ##

  belongs_to :budget,            :inverse_of => :components
  belongs_to :component_model,   :inverse_of => :components, :counter_cache => true
  belongs_to :kit,               :inverse_of => :components
  has_many   :inventory_details, :inverse_of => :component
  has_many   :inventory_records, :through    => :inventory_details


  ## Validations ##

  validates :asset_tag,       :uniqueness => { :case_sensitive => false }, :allow_nil => true
  validates :component_model, :presence => true
  validates :serial_number,   :uniqueness => { :case_sensitive => false }, :allow_nil => true


  ## Mass-assignable attributes ##

  attr_accessible(:asset_tag,
                  :budget_id,
                  :kit_id,
                  :component_model_id,
                  :position,
                  :serial_number)


  ## Class Methods ##

  def self.missing
    joins_sql = <<-END_SQL
    INNER JOIN (SELECT inventory_records.kit_id, max(created_at) as max_created_at
                FROM inventory_records
                GROUP BY inventory_records.kit_id) AS t1 ON (t1.kit_id = inventory_records.kit_id AND t1.max_created_at = inventory_records.created_at)

    END_SQL

    # INNER JOIN kits ON components.kit_id = kits.id
    # INNER JOIN inventory_details ON components.id = inventory_details.component_id
    # INNER JOIN inventory_records ON inventory_details.inventory_record_id = inventory_records.id

    self
      .includes(:kit, :inventory_details => :inventory_record)
      .joins(:kit,    :inventory_details => :inventory_record)
      .joins(joins_sql)
      .where("inventory_details.missing = ? AND kits.workflow_state <> 'deaccessioned'", true)

  end

  ## Instance Methods ##

  def current_inventory_detail
    inventory_details.order("inventory_record_id DESC").limit(1).first
  end

  def training_required?(user = nil)
    component_model.training_required?(user)
  end

  private

  def autofill_accessioned_at
    accessioned_at = DateTime.current unless accessioned_at
  end

  def upcase_serial_number
    serial_number.upcase! unless serial_number.nil?
  end

end
