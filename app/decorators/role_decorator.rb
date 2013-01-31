class RoleDecorator < ApplicationDecorator
  decorates :role

  def name
    h.h(source.name)
  end
end
