class UserDecorator < ApplicationDecorator
  decorates :user

  allows(:created_at,
         :current_sign_in_at,
         :disabled,
         :email,
         :failed_attempts,
         :last_sign_in_at,
         :locked_at,
         :sign_in_count,
         :suspended_until,
         :suspension_count,
         :username)

  def disabled
    to_yes_no(model.disabled)
  end

  def suspended_until
    localize_unless_nil(model.suspended_until, :format => :tabular)
  end

  def current_sign_in_at
    localize_unless_nil(model.current_sign_in_at, :format => :db)
  end

  def last_sign_in_at
    localize_unless_nil(model.current_sign_in_at, :format => :db)
  end

  def locked_at
    localize_unless_nil(model.locked_at, :format => :db)
  end

  def created_at
    localize_unless_nil(model.created_at, :format => :db)
  end

  def updated_at
    localize_unless_nil(model.updated_at, :format => :db)
  end
end
