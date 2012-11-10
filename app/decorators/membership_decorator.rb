class MembershipDecorator < ApplicationDecorator
  decorates :membership
  decorates_association :group
  decorates_association :user

  def username
    model.user.username
  end

  def expires_at
    if model.expires_at.nil?
      return "Never"
    else
      return localize_unless_nil(model.expires_at, :format => :tabular)
    end
  end

end
