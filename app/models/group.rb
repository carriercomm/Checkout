class Group < ActiveRecord::Base

  ## Associations ##

  has_and_belongs_to_many :users


  ## Mass-assignable Attributes ##

  attr_accessible(:expires_at,
                  :name,
                  :user_ids)

end
