class UserDecorator < ApplicationDecorator
  decorates :user
  decorates_association :covenants
  decorates_association :groups
  decorates_association :roles

  allows(:created_at,
         :disabled?,
         :failed_attempts,
         :last_sign_in_at,
         :locked_at,
         :memberships,
         :save,
         :sign_in_count,
         :suspension_count,
         :suspended?,
         :to_s,
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

  def description
    text = h.link_to(model.username, h.user_path(model))
    text << " (#{ full_name })".html_safe if model.first_name && model.last_name
    text
  end

  def disabled
    to_yes_no(model.disabled)
  end

  def email
    h.mail_to(model.email)
  end

  def first_name
    coalesce(model.first_name)
  end

  def full_name
    @full_name ||= "#{ h.h(model.first_name) } #{ h.h(model.last_name) }".squish
  end

  def last_name
    coalesce(model.last_name)
  end

  def groups_list(separator = ", ")
    return "&nbsp;".html_safe if groups.empty?
    groups.map(&:to_link).join(separator).html_safe
  end

  def last_sign_in_at
    localize_unless_nil(model.current_sign_in_at, :format => :db)
  end

  def locked_at
    localize_unless_nil(model.locked_at, :format => :db)
  end

  def roles_list(separator = ", ")
    return "&nbsp;".html_safe if model.roles.empty?
    separator.html_safe
    role_names = model.roles.collect {|r| h.t("role.#{ r.name }") }
    role_names.join(separator).html_safe
  end

  def select2_json
    {
      :id   => model.id,
      :text => model.to_s
    }
  end

  def status_icon
    if model.disabled
      h.t("user.status.disabled.icon").html_safe
    elsif model.suspended?
      h.t("user.status.suspended.icon").html_safe
    else
      h.t("user.status.active.icon").html_safe
    end
  end

  def suspended_until
    localize_unless_nil(model.suspended_until, :format => :tabular)
  end

  def tabular_full_name
    h.content_tag("div", title: full_name) do
      full_name
    end
  end

  def to_s
    description
  end

  def updated_at
    localize_unless_nil(model.updated_at, :format => :db)
  end

  def username
    h.link_to(model.username, h.user_path(model), :title=> model.username)
  end
end
