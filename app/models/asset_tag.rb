class AssetTag < ActiveRecord::Base
  belongs_to :part

  attr_accessible :uid, :part_id

end
