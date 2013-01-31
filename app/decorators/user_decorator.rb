class UserDecorator < ApplicationDecorator
  decorates :user
  decorates_association :covenants
  decorates_association :groups
  decorates_association :memberships
  decorates_association :roles
  decorates_association :trainings

  delegate(:disabled?,
           :failed_attempts,
           :map,
           :memberships,
           :save,
           :sign_in_count,
           :suspension_count,
           :suspended?)

  def autocomplete_json(options={})
    {
      :label => username,
      :value => h.url_for(source)
    }
  end

  def created_at
    localize_unless_nil(source.created_at, :format => :db)
  end

  def current_sign_in_at
    localize_unless_nil(source.current_sign_in_at, :format => :db)
  end

  def description
    text = h.link_to(source.username, h.user_path(source))
    text << " (#{ full_name })".html_safe if source.first_name && source.last_name
    text
  end

  def disabled
    to_yes_no(source.disabled)
  end

  def email
    h.mail_to(source.email)
  end

  def first_name
    coalesce(source.first_name)
  end

  def full_name
    @full_name ||= "#{ h.h(source.first_name) } #{ h.h(source.last_name) }".squish
  end

  def last_name
    coalesce(source.last_name)
  end

  def groups_list(separator = ", ")
    return "&nbsp;".html_safe if groups.empty?
    groups.map(&:to_link).join(separator).html_safe
  end

  def last_sign_in_at
    localize_unless_nil(source.current_sign_in_at, :format => :db)
  end

  def locked_at
    localize_unless_nil(source.locked_at, :format => :db)
  end

  def roles_list(separator = ", ")
    return "&nbsp;".html_safe if source.roles.empty?
    separator.html_safe
    role_names = source.roles.collect {|r| h.t("role.#{ r.name }") }
    role_names.join(separator).html_safe
  end

  def select2_json
    {
      :id   => source.id,
      :text => source.to_s
    }
  end

  def status_icon
    if source.disabled
      h.t("user.status.disabled.icon").html_safe
    elsif source.suspended?
      h.t("user.status.suspended.icon").html_safe
    else
      h.t("user.status.active.icon").html_safe
    end
  end

  def suspended_until
    localize_unless_nil(source.suspended_until, :format => :tabular)
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
    localize_unless_nil(source.updated_at, :format => :db)
  end

  def username
    h.link_to(source.username, h.user_path(source), :title=> source.username)
  end
end
