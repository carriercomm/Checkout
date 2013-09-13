class UserDecorator < ApplicationDecorator
  decorates :user
  decorates_association :covenants
  decorates_association :groups
  decorates_association :memberships
  decorates_association :roles
  decorates_association :trainings

  delegate(:as_json,
           :disabled?,
           :failed_attempts,
           :map,
           :memberships,
           :save,
           :sign_in_count,
           :suspension_count,
           :suspended?)

  def autocomplete_json(options={})
    {
      :label => username_and_full_name,
      :value => h.url_for(object),
      :category => h.t("user.index.title").html_safe
    }
  end

  def created_at
    localize_unless_nil(object.created_at, :format => :db)
  end

  def current_sign_in_at
    localize_unless_nil(object.current_sign_in_at, :format => :db)
  end

  def description
    text = h.link_to(object.username, h.user_path(object))
    text << " (#{ full_name })".html_safe if object.first_name && object.last_name
    text
  end

  def disabled
    to_yes_no(object.disabled)
  end

  def email
    h.mail_to(object.email)
  end

  def first_name
    coalesce(object.first_name)
  end

  def full_name
    @full_name ||= coalesce("#{ object.first_name } #{ object.last_name }".squish)
  end

  def last_name
    coalesce(object.last_name)
  end

  def groups_list(separator = ", ")
    return "&nbsp;".html_safe if groups.empty?
    groups.map(&:to_link).join(separator).html_safe
  end

  def last_sign_in_at
    localize_unless_nil(object.current_sign_in_at, :format => :db)
  end

  def locked_at
    localize_unless_nil(object.locked_at, :format => :db)
  end

  def roles_list(separator = ", ")
    return "&nbsp;".html_safe if object.roles.empty?
    separator.html_safe
    role_names = object.roles.collect {|r| h.t("role.#{ r.name }") }
    role_names.join(separator).html_safe
  end

  def select2_json
    {
      :id   => object.id,
      :text => object.to_s
    }
  end

  def status
    if object.disabled
      return :disabled
    elsif object.suspended?
      return :suspended
    else
      return :active
    end
  end

  def suspended_until
    localize_unless_nil(object.suspended_until, :format => :tabular)
  end

  def tabular_full_name
    h.content_tag("div", title: full_name) do
      full_name
    end
  end

  def to_link
    h.link_to(object.username, h.user_path(object), rel: "tooltip", title: full_name, class: "user user-status-#{ status.to_s }")
  end

  def to_s
    username
  end

  def to_select2_s
    object.username
  end

  def updated_at
    localize_unless_nil(object.updated_at, :format => :db)
  end

  def username
    object.username
  end

  def username_and_full_name
    "#{ object.username } (#{ full_name })"
  end

end
