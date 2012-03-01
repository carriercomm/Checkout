class Model < ActiveRecord::Base

  belongs_to :brand
  has_many   :parts
  has_many   :kits, :through => :parts

  has_and_belongs_to_many :categories

end

