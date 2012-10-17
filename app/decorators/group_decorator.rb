class GroupDecorator < ApplicationDecorator
  decorates :group
  decorates_association :memberships
  decorates_association :kits
  decorates_association :users

  def to_link
    h.link_to(model.name, h.group_path(model))
  end

  def to_s
    model.name
  end

end
