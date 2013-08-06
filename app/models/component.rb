class Component < ActiveRecord::Base

  ## Macros ##

  acts_as_list :scope => :kit
  resourcify
  strip_attributes


  ## Callbacks ##

  before_validation :upcase_serial_number


  ## Associations ##

  belongs_to :component_model,   :inverse_of => :components
  belongs_to :kit,               :inverse_of => :components
  has_many   :inventory_records, :inverse_of => :component

  ## Validations ##

  validates_presence_of :component_model
  # removing this so there's some mechanism for moving components from
  # one kit to another
  # validates_presence_of :kit
  validates :asset_tag,     :uniqueness => { :case_sensitive => false }, :allow_nil => true
  validates :serial_number, :uniqueness => { :case_sensitive => false }, :allow_nil => true


  ## Mass-assignable attributes ##

  attr_accessible(:asset_tag,
                  :kit_id,
                  :missing,
                  :component_model_id,
                  :position,
                  :serial_number)

  ## Virtual attributes ##

  attr_reader :component_model_name


  ## Instance Methods ##

  def latest_inventory_record
    inventory_records.order("created_at DESC").limit(1).first
  end

  def training_required?(user = nil)
    component_model.training_required?(user)
  end

  private

  def upcase_serial_number
    serial_number.upcase! unless serial_number.nil?
  end

end
