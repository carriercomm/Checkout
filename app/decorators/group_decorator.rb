class GroupDecorator < ApplicationDecorator
  decorates :group
  decorates_association :users

  def name
    h.link_to h.h(model.name), h.group_path(model)
  end

  def expires_at
    if model.expires_at.nil?
      return "Never"
    else
      return localize_unless_nil(model.expires_at, :format => :tabular)
    end
  end

end
