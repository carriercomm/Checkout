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
                  :permissions_attributes,
                  :name)

  accepts_nested_attributes_for(:memberships,
                                :reject_if => proc { |attributes| attributes['user_id'].blank? },
                                :allow_destroy=> true)

  accepts_nested_attributes_for(:permissions,
                                :reject_if => proc { |attributes| attributes['kit_id'].blank? },
                                :allow_destroy=> true)

  def to_param
    "#{ id } #{ name }".parameterize
  end

end
