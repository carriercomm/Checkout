class Part < ActiveRecord::Base

  belongs_to :budget
  belongs_to :kit
  belongs_to :model
  has_many   :asset_tags

  accepts_nested_attributes_for :model

  def to_param
    if new_record?
      return id
    else
      "#{ id } #{ model.brand.name } #{ model.name }".parameterize
    end
  end

end

