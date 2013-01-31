class CovenantDecorator < ApplicationDecorator
  decorates :covenant
  delegate  :name, :description
end
