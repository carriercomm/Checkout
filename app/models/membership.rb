class Membership < ActiveRecord::Base

  ## Macros ##

  strip_attributes


  ## Associations ##

  belongs_to :group, :inverse_of => :memberships
  belongs_to :user, :inverse_of => :memberships

  ## Mass-assignable Attributes ##

  attr_accessible(:expires_at,
                  :group_id,
                  :user_id)

end
