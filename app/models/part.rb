class Part < ActiveRecord::Base

  belongs_to :budget
  belongs_to :kit
  belongs_to :model
  has_many   :asset_tags

  def model_options_map
    model.brand.models.order(:name).all.map { |m| [m.name, m.id] }
  end

  def to_param
    if new_record?
      return id
    else
      "#{ id } #{ model.brand.name } #{ model.name }".parameterize
    end
  end

end

