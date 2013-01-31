class MembershipDecorator < ApplicationDecorator
  decorates :membership
  decorates_association :group
  decorates_association :user

  delegate :persisted?, :id

  def expires_at
    if source.expires_at.nil?
      return "Never"
    else
      return localize_unless_nil(source.expires_at, :format => :tabular)
    end
  end

  def username
    source.user.username
  end

  def supervisor
    to_yes_no(source.supervisor)
  end

end
