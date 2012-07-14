class Component < ActiveRecord::Base

  acts_as_list


  #
  # Callbacks
  #

  before_validation :upcase_serial_number


  #
  # Associations
  #

  belongs_to :model, :inverse_of => :components
  belongs_to :kit,   :inverse_of => :components


  #
  # Validations
  #
  
  validates_presence_of :model
  validates_presence_of :kit
  validates :asset_tag,     :uniqueness => true, :allow_nil => true
  validates :serial_number, :uniqueness => true, :allow_nil => true
  

  #
  # Mass-assignable attributes
  #

  attr_accessible(:asset_tag,
                  :kit_id,
                  :missing,
                  :model_id,
                  :position,
                  :serial_number)

  private

  def upcase_serial_number
    serial_number.upcase! unless serial_number.nil?
  end

end
