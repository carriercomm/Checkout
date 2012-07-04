class Component < ActiveRecord::Base

  belongs_to :kit
  has_many   :asset_tags

  validates :kit_id, :presence => true
  validates :serial_number, :uniqueness => true

  # accepts_nested_attributes_for :model

  # def to_param
  #   if new_record?
  #     return id
  #   else
  #     "#{ id } #{ model.brand.name } #{ model.name }".parameterize
  #   end
  # end

end
