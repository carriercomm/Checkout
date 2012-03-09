class Category < ActiveRecord::Base
  has_and_belongs_to_many :models

  default_scope order("categories.name ASC")

end
