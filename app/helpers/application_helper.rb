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
  # def sidebar_link(text, path, default_tooltip = "", condition = true, failure_tooltip = nil, options = {})
  #   # setup the base options for the tooltip
  #   link_opts = {
  #     "rel"            => "tooltip",
  #     "data-placement" => "right"
  #   }

  #   li_opts = {}

  #   # if the link is to the current page, then we'll highlight it
  #   # TODO: make this work for the root url
  #   li_opts[:class] = "active" if current_page?(path)

  #   if condition
  #     link_opts['data-title'] = default_tooltip unless default_tooltip.blank?
  #     content_tag :li, li_opts do
  #       link_to raw(text), path, link_opts.merge(options)
  #     end
  #   else
  #     link_opts['data-title'] = failure_tooltip unless failure_tooltip.blank?
  #     link_opts[:class] = "disabled"
  #     link_opts[:onclick] = "return false;"
  #     content_tag :li do
  #       link_to raw(text), "#", link_opts
  #     end
  #   end
  # end

  def sortable(column, title)
    title ||= column.titleize
    title = h(title)
    direction = begin
      if column == sort_column
        if sort_direction == "asc"
          title << ' <i class="icon-sort-down"></i>'.html_safe
          "desc"
        else
          title << ' <i class="icon-sort-up"></i>'.html_safe
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

  # def admin_link(object, content)
  #   link_to(content, object) if current_user.admin?
  # end

  # def attendant_link(object, content)
  #   link_to(content, object) if current_user.attendant?
  # end

  # def attendant_mini_button(object, content)
  #   link_to(content, object, class: 'btn btn-mini') if current_user.attendant?
  # end

  # # TODO: DRY this up
  # def checkout_link(object)
  #   if object.is_a?(LoanDecorator)
  #     link_to(t('helpers.links.checkout'), [:edit, object.model], a:'checkout')
  #   elsif object.is_a?(Loan)
  #     link_to(t('helpers.links.checkout'), [:edit, object], a:'checkout')
  #   else
  #     if object.circulating? && current_user.attendant?
  #       loan_link(t('helpers.links.checkout'), object, a:'checkout')
  #     end
  #   end
  # end

  # def checkout_mini_button(object)
  #   if object.circulating? && current_user.attendant?
  #     loan_mini_button(t('helpers.links.checkout'), object, a:'checkout')
  #   end
  # end

  # def inventory_shortcuts
  #   links = InventoryStatusDecorator.all.map do |is|
  #     "<a href='#' class='inventory_record_shortcut' data-value='#{ is.id }'>#{ is.name }</a>"
  #   end
  #   links.join(", ").html_safe
  # end

  # def reserve_link(object)
  #   if object.circulating? && object.reservable?(current_user)
  #     loan_link(t('helpers.links.reserve'), object)
  #   end
  # end

  # def reserve_mini_button(object)
  #   if object.circulating? && object.reservable?(current_user)
  #     reservation_mini_button(t('helpers.links.reserve'), object)
  #   end
  # end

  # def show_link(object, content = t("helpers.links.show"))
  #   object = object.model if object.is_a? Draper::Decorator
  #   if (can?(:show, object) || can?(:read, object))
  #     link_to(content, object)
  #   else
  #     content
  #   end
  # end

  # def show_mini_button(object, content = t("helpers.links.show"))
  #   link_to(content, object, class: 'btn btn-mini') if can?(:read, object)
  # end

  # def edit_link(object, content = t("helpers.links.edit"))
  #   link_to(content, [:edit, object]) if can?(:update, object)
  # end

  # def destroy_link(object, content = t("helpers.links.destroy"))
  #   link_to(content, object, :method => :delete, :confirm => "Are you sure?") if can?(:destroy, object)
  # end

  # def create_link(object, content = t("helpers.links.new"))
  #   if can?(:create, object)
  #     object_class = (object.kind_of?(Class) ? object : object.class)
  #     link_to(content, [:new, object_class.name.underscore.to_sym])
  #   end
  # end

  def sidebar_link(action, object, options = {}, html_options = {})
    path = options.delete(:path)

    case action
    when :check_out
      path ||= if object.is_a?(Loan) || object.is_a?(LoanDecorator)
                 edit_loan_path(object)
               else
                 new_loan_path(object)
               end
      ability = options.delete(:ability) || :create
      html_options.reverse_merge!({
          :text   => "#{ t("helpers.mini_buttons.check_out") } #{ t("helpers.actions.check_out") }".html_safe,
          :class  => 'btn btn-link',
          :method => :get,
        })
    when :reserve
      path ||= new_loan_path(object)
      ability = options.delete(:ability) || :create
      html_options.reverse_merge!({
          :text   => "#{ t("helpers.mini_buttons.reserve") } #{ t("helpers.actions.reserve") }".html_safe,
          :class  => 'btn btn-link',
          :method => :get,
        })
    when :new
      path ||= url_for(controller: object.class.to_s.tableize, action: :new)
      ability = options.delete(:ability) || :create
      html_options.reverse_merge!({
          :text   => "#{ t("helpers.mini_buttons.new") } #{ t("helpers.actions.new") }".html_safe,
          :class  => 'btn btn-link',
          :method => :get,
        })
    when :edit
      path ||= [:edit, object]
      ability = options.delete(:ability) || :update
      html_options.reverse_merge!({
          :text   => "#{ t("helpers.mini_buttons.edit") } #{ t("helpers.actions.edit") }".html_safe,
          :class  => 'btn btn-link',
          :method => :get,
        })
    when :index
      raise "Need an expicit path parameter in options when object is a collection" unless path
      ability = options.delete(:ability) || :read
      html_options.reverse_merge!({
          :text   => "#{ t("helpers.mini_buttons.index") } #{ t("helpers.actions.index") }".html_safe,
          :class  => 'btn btn-link',
          :method => :get
        })
    when :show
      path = object
      ability = options.delete(:ability) || :read
      html_options.reverse_merge!({
          :text   => "#{ t("helpers.mini_buttons.show") } #{ t("helpers.actions.show") }".html_safe,
          :class  => 'btn btn-link',
          :method => :get
        })
    else
      raise "unknown action"
    end

    # authorize the action
    unless can?(ability, object)
      html_options.merge!("disabled" => "disabled")
    end

    text = html_options.delete(:text)
    #button_to(text, path, options)
    content_tag :li do
      my_button_to(path, html_options) do
        text
      end
    end
  end

  # TODO: convert this to accept a block
  def mini_button(action, object, options = {}, html_options = {})
    path = options.delete(:path)

    case action
    when :check_in
      path ||= edit_loan_path(object)

      ability = options.delete(:ability) || :manage
      unless object.checked_out?
        html_options.reverse_merge!({ "disabled" => "disabled" })
      end
      html_options.reverse_merge!({
          :text   => t("helpers.mini_buttons.check_in").html_safe,
          :title  => t("helpers.actions.check_in"),
        })
    when :check_out
      path ||= if object.is_a?(Loan) || object.is_a?(LoanDecorator)
                 edit_loan_path(object)
                 if object.approved? || current_user.attendant?
                   html_options.reverse_merge!({ "disabled" => "disabled" })
                 end
               else
                 new_loan_path(object)
               end
      ability = options.delete(:ability) || :manage
      html_options.reverse_merge!({
          :text   => t("helpers.mini_buttons.check_out").html_safe,
          :title  => t("helpers.actions.check_out"),
        })
    when :reserve
      path ||= new_loan_path(object)
      ability = options.delete(:ability) || :create
      html_options.reverse_merge!({
          :text   => t("helpers.mini_buttons.reserve").html_safe,
          :title  => t("helpers.actions.reserve"),
        })
    when :edit
      path ||= [:edit, object]
      ability = options.delete(:ability) || :update
      html_options.reverse_merge!({
          :text   => t("helpers.mini_buttons.edit").html_safe,
          :title  => t("helpers.actions.edit"),
        })
    when :index
      raise "Need an expicit path parameter in options when object is a collection" unless path
      ability = options.delete(:ability) || :read
      html_options.reverse_merge!({
          :text   => t("helpers.mini_buttons.index").html_safe,
          :title  => t("helpers.actions.index"),
        })
    when :show
      path = object
      ability = options.delete(:ability) || :read
      html_options.reverse_merge!({
          :text   => t("helpers.mini_buttons.show").html_safe,
          :title  => t("helpers.actions.show"),
        })
    else
      raise "unknown action"
    end

    # defaults for all buttons
    html_options.reverse_merge!({
        :method      => :get,
        :class       => 'btn btn-mini',
        :rel         => "tooltip",
        'data-delay' => 500
      })

    # authorize the action
    unless can?(ability, object)
      html_options.reverse_merge!("disabled" => "disabled")
    end

    text = html_options.delete(:text)
    my_button_to(path, html_options) do
      text
    end
  end

  private

  def my_button_to(options = {}, html_options = {}, &block)
    html_options = html_options.stringify_keys
    #convert_boolean_attributes!(html_options, %( disabled ))

    method_tag = ''
    if (method = html_options.delete('method')) && %{put delete}.include?(method.to_s)
      method_tag = tag('input', :type => 'hidden', :name => '_method', :value => method.to_s)
    end

    form_method = method.to_s == 'get' ? 'get' : 'post'
    form_options = html_options.delete('form') || {}
    form_options[:class] ||= html_options.delete('form_class') || 'my_button_to'

    remote = html_options.delete('remote')

    request_token_tag = ''
    if form_method == 'post' && protect_against_forgery?
      request_token_tag = tag(:input, :type => "hidden", :name => request_forgery_protection_token.to_s, :value => form_authenticity_token)
    end

    url = options.is_a?(String) ? options : self.url_for(options)
    name ||= url

    html_options = convert_options_to_data_attributes(options, html_options)

    html_options.merge!("type" => "submit")
    html_options.merge!("name" => nil)

    form_options.merge!(:method => form_method, :action => url)
    form_options.merge!("data-remote" => "true") if remote

    "#{tag(:form, form_options, true)}#{method_tag}#{button_tag(nil, html_options, &block)}#{request_token_tag}</form>".html_safe
  end



  # TODO: DRY this up
  # def loan_mini_button(text, object, options={})
  #   path = String.new

  #   case object.class.to_s
  #   when "ComponentModel"
  #     path = new_component_model_loan_path(object, options)
  #   when "ComponentModelDecorator"
  #     path = new_component_model_reservation_path(object.model, options)
  #   when "Kit"
  #     path = new_kit_loan_path(object, options)
  #   when "KitDecorator"
  #     path = new_kit_loan_path(object.model, options)
  #   else
  #     raise "Expected an instance of Kit, KitDecorator, ComponentModel or ComponentModelDecorator, got: #{ object.class }"
  #   end
  #   link_to(text, path, :class => 'btn btn-mini')
  # end

  # def loan_link(text, object, options={})
  #   path = String.new

  #   case object.class.to_s
  #   when "ComponentModel"
  #     path = new_component_model_loan_path(object, options)
  #   when "ComponentModelDecorator"
  #     path = new_component_model_loan_path(object.model, options)
  #   when "Kit"
  #     path = new_kit_loan_path(object, options)
  #   when "KitDecorator"
  #     path = new_kit_loan_path(object.model, options)
  #   else
  #     raise "Expected an instance of Kit, KitDecorator, ComponentModel or ComponentModelDecorator, got: #{ object.class }"
  #   end
  #   link_to(text, path)
  # end

  # # TODO: DRY this up
  # def reservation_mini_button(text, object, options={})
  #   path = String.new

  #   case object.class.to_s
  #   when "ComponentModel"
  #     path = new_component_model_reservation_path(object, options)
  #   when "ComponentModelDecorator"
  #     path = new_component_model_reservation_path(object.model, options)
  #   when "Kit"
  #     path = new_kit_reservation_path(object, options)
  #   when "KitDecorator"
  #     path = new_kit_reservation_path(object.model, options)
  #   else
  #     raise "Expected an instance of Kit, KitDecorator, ComponentModel or ComponentModelDecorator, got: #{ object.class }"
  #   end
  #   link_to(text, path, :class => 'btn btn-mini')
  # end

end
