class Membership < ActiveRecord::Base

  ## Macros ##

  strip_attributes


  ## Associations ##

  belongs_to :group, :inverse_of => :memberships
  belongs_to :user, :inverse_of => :memberships

  ## Mass-assignable Attributes ##

  attr_accessible(:expires_at,
                  :group_id,
                  :supervisor,
                  :user_id)

  validates :group_id, :presence => true
  validates :user_id,  :presence => true
  validates :user_id,  :uniqueness => { :scope => :group_id }

  def username
    user.username
  end

end
