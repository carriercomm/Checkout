class Permission < ActiveRecord::Base

  ## Macros ##

  strip_attributes


  ## Associations ##

  belongs_to :group
  belongs_to :kit


  ## Mass-assignable attributes ##

  attr_accessible(:kit_id, :exclusive_until, :expires_at)

  def data_text
    return if new_record?
    KitDecorator.decorate(kit).description
  end

end
