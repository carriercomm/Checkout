class UserDecorator < ApplicationDecorator
  decorates :user
  decorates_association :covenants
  decorates_association :groups
  decorates_association :roles

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

  def autocomplete_json(options={})
    {
      :label => username,
      :value => h.url_for(model)
    }
  end

  def created_at
    localize_unless_nil(model.created_at, :format => :db)
  end

  def current_sign_in_at
    localize_unless_nil(model.current_sign_in_at, :format => :db)
  end

  def disabled
    to_yes_no(model.disabled)
  end

  def first_name
    val_or_space(model.first_name)
  end

  def last_name
    val_or_space(model.last_name)
  end

  def groups_list(separator = ", ")
    return "&nbsp;".html_safe if groups.empty?
    groups.map(&:name).join(separator).html_safe
  end

  def last_sign_in_at
    localize_unless_nil(model.current_sign_in_at, :format => :db)
  end

  def locked_at
    localize_unless_nil(model.locked_at, :format => :db)
  end

  def roles_list(separator = ", ")
    return "&nbsp;".html_safe if roles.empty?
    separator.html_safe
    roles.map(&:name).join(separator).html_safe
  end

  def status
    if model.disabled
      h.t("user.status.disabled").html_safe
    elsif !model.suspended_until.nil? && model.suspended_until > Time.now
      h.t("user.status.suspended").html_safe
    else
      h.t("user.status.active").html_safe
    end
  end

  def suspended_until
    localize_unless_nil(model.suspended_until, :format => :tabular)
  end

  def updated_at
    localize_unless_nil(model.updated_at, :format => :db)
  end
end
