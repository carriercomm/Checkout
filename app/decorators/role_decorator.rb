class RoleDecorator < ApplicationDecorator
  decorates :role

  def name
    h.h(model.name)
  end
end
