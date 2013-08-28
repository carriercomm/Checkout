class Permission < ActiveRecord::Base

  ## Macros ##

  strip_attributes


  ## Associations ##

  belongs_to :group, :inverse_of => :permissions
  belongs_to :kit,   :inverse_of => :permissions


  ## Validations ##

  validates :group, :presence => true
  validates :kit,   :presence => true
  validate  :validate_unique_kit_per_group


  ## Mass-assignable attributes ##

  attr_accessible(:kit_id, :exclusive_until, :expires_at)

  # TODO: delete me
  # Figure out how to use decorated models with Simple Form.
  # def data_text
  #   return if new_record?
  #   KitDecorator.decorate(kit).description
  # end

  def validate_unique_kit_per_group
    if self.class.exists?(:kit_id => kit_id, :group_id => group_id)
      errors.add :kit, 'already exists in this group'
    end
  end

end
