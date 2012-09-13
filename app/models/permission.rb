class Permission < ActiveRecord::Base

  ## Macros ##

  strip_attributes


  ## Associations ##

  belongs_to :group
  belongs_to :kit


  ## Mass-assignable attributes ##

  attr_accessible :exclusive_until, :expires_at
end
