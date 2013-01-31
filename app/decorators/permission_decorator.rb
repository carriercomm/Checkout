class PermissionDecorator < ApplicationDecorator
  decorates :permission
  decorates_association :group
  decorates_association :kit

end
