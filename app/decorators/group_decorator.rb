class GroupDecorator < ApplicationDecorator
  decorates :group
  decorates_association :memberships
  decorates_association :kits
  decorates_association :users

  delegate :description, :id, :name

  def num_kits
    coalesce(source.attributes["num_kits"], "0")
  end

  def num_users
    coalesce(source.attributes["num_users"], "0")
  end

  def to_link
    h.link_to(source.name, h.group_path(model))
  end

  def to_s
    source.name
  end

end
