class Group < ActiveRecord::Base

  ## Macros ##

  resourcify
  strip_attributes

  ## Associations ##

  has_many :memberships, :inverse_of => :group
  has_many :users, :through => :memberships, :order => "users.username ASC"
  has_many :permissions, :inverse_of => :group, :dependent => :destroy
  has_many :kits, :through => :permissions

  ## Mass-assignable Attributes ##

  attr_accessible(:description,
                  :expires_at,
                  :memberships_attributes,
                  :name)

  accepts_nested_attributes_for :memberships

  def to_param
    "#{ id } #{ name }".parameterize
  end

end
