module ApplicationHelper

  def active(path)
    (current_page? path) ? 'class="active"'.html_safe : ""
  end

  def dropdown_for(name, icon_class = nil, &block)
    content_tag("li", :class=>"dropdown") do
      link_text = String.new
      link_text << '<i class="' + icon_class + '"></i>' unless icon_class.nil?
      link_text << name.html_safe
      link_text << '<b class="caret"></b>'

      link_to(raw(link_text), "#", :class=>"dropdown-toggle", "data-toggle" =>"dropdown") +
        content_tag("ul", :class=>"dropdown-menu", &block)
    end
  end

  # TODO: ummm, this is clumsy. Like... no, really. It's actually embarrassing me.
  def sidebar_link(text, path, default_tooltip = "", condition = true, failure_tooltip = nil, options = {})
    # setup the base options for the tooltip
    link_opts = {
      :rel   => "tooltip",
      "data-placement" => "right"
    }

    li_opts = {}

    # if the link is to the current page, then we'll highlight it
    # TODO: make this work for the root url
    li_opts[:class] = "active" if current_page?(path)

    if condition
      link_opts[:title] = default_tooltip unless default_tooltip.blank?
      content_tag :li, li_opts do
        link_to raw(text), path, link_opts.merge(options)
      end
    else
      link_opts[:title] = failure_tooltip unless failure_tooltip.blank?
      link_opts[:class] = "disabled"
      link_opts[:onclick] = "return false;"
      content_tag :li do
        link_to raw(text), "#", link_opts
      end
    end
  end

  def sortable(column, title)
    title ||= column.titleize
    title = h(title)
    direction = begin
      if column == sort_column
        if sort_direction == "asc"
          title << ' <i class="icon-arrow-down"></i>'.html_safe
          "desc"
        else
          title << ' <i class="icon-arrow-up"></i>'.html_safe
          "asc"
        end
      else
        nil
      end
    end
    link_to(title.html_safe, :sort => column, :direction => direction)
  end

  def subtitle(page_subtitle)
    content_for(:subtitle, page_subtitle)
  end

  def title(page_title)
    content_for(:title, page_title)
  end

  def admin_link(object, content)
    link_to(content, object) if current_user.admin?
  end

  def attendant_link(object, content)
    link_to(content, object) if current_user.attendant?
  end

  def attendant_mini_button(object, content)
    link_to(content, object, class: 'btn btn-mini') if current_user.attendant?
  end

  # TODO: DRY this up
  def checkout_link(object)
    if object.is_a?(LoanDecorator)
      link_to(t('helpers.links.checkout'), [:edit, object.model], a:'checkout')
    elsif object.is_a?(Loan)
      link_to(t('helpers.links.checkout'), [:edit, object], a:'checkout')
    else
      if object.checkoutable? && current_user.attendant?
        loan_link(t('helpers.links.checkout'), object, a:'checkout')
      end
    end
  end

  def checkout_mini_button(object)
    if object.checkoutable? && current_user.attendant?
      loan_mini_button(t('helpers.links.checkout'), object, a:'checkout')
    end
  end

  def reserve_link(object)
    if object.checkoutable? && object.reservable?(current_user)
      loan_link(t('helpers.links.reserve'), object)
    end
  end

  def reserve_mini_button(object)
    if object.checkoutable? && object.reservable?(current_user)
      loan_mini_button(t('helpers.links.reserve'), object)
    end
  end

  def show_link(object, content = t("helpers.links.show"))
    link_to(content, object) if can?(:read, object)
  end

  def show_mini_button(object, content = t("helpers.links.show"))
    link_to(content, object, class: 'btn btn-mini') if can?(:read, object)
  end

  def edit_link(object, content = t("helpers.links.edit"))
    link_to(content, [:edit, object]) if can?(:update, object)
  end

  def edit_mini_button(object, content = t("helpers.links.edit"))
    link_to(content, [:edit, object], class: 'btn btn-mini') if can?(:update, object)
  end

  def destroy_link(object, content = t("helpers.links.destroy"))
    link_to(content, object, :method => :delete, :confirm => "Are you sure?") if can?(:destroy, object)
  end

  def create_link(object, content = t("helpers.links.new"))
    if can?(:create, object)
      object_class = (object.kind_of?(Class) ? object : object.class)
      link_to(content, [:new, object_class.name.underscore.to_sym])
    end
  end

  private

  # TODO: DRY this up
  def loan_mini_button(text, object, options={})
    path = String.new

    case object.class.to_s
    when "ComponentModel"
      path = new_component_model_loan_path(object, options)
    when "ComponentModelDecorator"
      path = new_component_model_loan_path(object.model, options)
    when "Kit"
      path = new_kit_loan_path(object, options)
    when "KitDecorator"
      path = new_kit_loan_path(object.model, options)
    else
      raise "Expected an instance of Kit, KitDecorator, ComponentModel or ComponentModelDecorator, got: #{ object.class }"
    end
    link_to(text, path, :class => 'btn btn-mini')
  end

  def loan_link(text, object, options={})
    path = String.new

    case object.class.to_s
    when "ComponentModel"
      path = new_component_model_loan_path(object, options)
    when "ComponentModelDecorator"
      path = new_component_model_loan_path(object.model, options)
    when "Kit"
      path = new_kit_loan_path(object, options)
    when "KitDecorator"
      path = new_kit_loan_path(object.model, options)
    else
      raise "Expected an instance of Kit, KitDecorator, ComponentModel or ComponentModelDecorator, got: #{ object.class }"
    end
    link_to(text, path)
  end


end
