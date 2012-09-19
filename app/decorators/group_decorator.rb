class GroupDecorator < ApplicationDecorator
  decorates :group
  decorates_association :memberships
  decorates_association :kits
  decorates_association :users

end
