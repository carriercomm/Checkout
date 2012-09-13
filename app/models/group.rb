class Group < ActiveRecord::Base

  ## Macros ##

  resourcify
  strip_attributes


  ## Associations ##

  has_and_belongs_to_many :users, :order => "users.username ASC"
  has_many :permissions, :inverse_of => :group
  has_many :kits, :through => :permissions

  ## Mass-assignable Attributes ##

  attr_accessible(:description,
                  :expires_at,
                  :name,
                  :user_ids)

  def to_param
    "#{ id } #{ name }".parameterize
  end

end
