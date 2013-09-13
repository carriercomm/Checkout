class Component < ActiveRecord::Base

  ## Macros ##

  acts_as_list :scope => :kit
  strip_attributes


  ## Callbacks ##

  before_create     :autofill_accessioned_at
  before_validation :upcase_serial_number


  ## Associations ##

  belongs_to :budget,            :inverse_of => :components
  belongs_to :component_model,   :inverse_of => :components
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


  ## Instance Methods ##

  def current_inventory_detail
    inventory_details.order("inventory_record_id DESC").limit(1).first
  end

  def training_required?(user = nil)
    component_model.training_required?(user)
  end

  private

  def autofill_accessioned_at
    accessioned_at = Time.zone.now.to_datetime unless accessioned_at
  end

  def upcase_serial_number
    serial_number.upcase! unless serial_number.nil?
  end

end
