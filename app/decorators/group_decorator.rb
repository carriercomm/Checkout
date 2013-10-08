class GroupDecorator < ApplicationDecorator
  decorates :group
  decorates_association :memberships
  decorates_association :kits
  decorates_association :users

  delegate :id, :name

  def description
    coalesce(object.description)
  end

  def num_kits
    coalesce(object.attributes["num_kits"], "0")
  end

  def num_users
    coalesce(object.attributes["num_users"], "0")
  end

  def to_link
    h.link_to(object.name, h.group_path(object))
  end

  def to_s
    object.name
  end

end
