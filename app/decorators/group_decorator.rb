class GroupDecorator < ApplicationDecorator
  decorates :group
  decorates_association :users

  def name
    val_or_space(model.name)
  end

  def expires_at
    if model.expires_at.nil?
      return "Never"
    else
      return localize_unless_nil(model.expires_at, :format => :tabular)
    end
  end

end
