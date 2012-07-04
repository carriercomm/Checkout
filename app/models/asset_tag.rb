class AssetTag < ActiveRecord::Base

  belongs_to :component

  attr_accessible :uid, :component_id

  validates :uid,          :presence   => true
  validates :uid,          :uniqueness => true
  validates :component_id, :presence   => true

end
