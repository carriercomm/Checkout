class Part < ActiveRecord::Base

  belongs_to :budget
  belongs_to :kit
  belongs_to :model
  has_many   :asset_tags

end

