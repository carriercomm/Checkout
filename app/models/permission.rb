class Permission < ActiveRecord::Base

  ## Macros ##

  strip_attributes


  ## Associations ##

  belongs_to :group, :inverse_of => :permissions
  belongs_to :kit,   :inverse_of => :permissions


  ## Mass-assignable attributes ##

  attr_accessible(:kit_id, :exclusive_until, :expires_at)

  validates_presence_of :group
  validates_presence_of :kit
  validates :kit_id, :uniqueness => { :scope => :group_id }

  # TODO: this is just lazy... what is this decorator doing in here?
  # Figure out how to use decorated models with Simple Form.
  def data_text
    return if new_record?
    KitDecorator.decorate(kit).description
  end

end
