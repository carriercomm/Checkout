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

  def auth_link(object, options = {}, html_options = {})
    params = get_link_params(object, options, html_options)

    if params[:authorized]
      link_to(params[:path], params[:html_options]) do
        params[:content]
      end
    else
      content_tag(:span, params[:html_options]) do
        params[:content]
      end
    end
  end

  private

  # when :check_out
  #   path ||= if object.is_a?(Loan) || object.is_a?(LoanDecorator)
  #              edit_loan_path(object)
  #            else
  #              new_loan_path(object)
  #            end
  #   ability = options.delete(:ability) || :create
  #   html_options.reverse_merge!({
  #       :text   => "#{ t("helpers.mini_buttons.check_out") } #{ t("helpers.actions.check_out") }".html_safe,
  #       :class  => 'btn btn-link',
  #       :method => :get,
  #     })
  # when :reserve
  #   path ||= new_loan_path(object)
  #   ability = options.delete(:ability) || :create
  #   html_options.reverse_merge!({
  #       :text   => "#{ t("helpers.mini_buttons.reserve") } #{ t("helpers.actions.reserve") }".html_safe,
  #       :class  => 'btn btn-link',
  #       :method => :get,
  #     })

  def extract_action(params)
    valid_actions = [:new, :edit]

    if params.is_a?(Array)
      if valid_actions.include?(params.first)       # [:new, :admin, Budget]
        return params.first
      elsif params.last.is_a?(ActiveRecord::Base)
        return :show                                # [:admin, @budget]
      else
        return :index                               # [:admin, Budget]
      end
    elsif params.is_a?(ActiveRecord::Base)
      return :show
    else
      return :index                                 # Budget
    end
  end

  def extract_class(params)
    valid_actions = [:new, :edit]
    target = nil
    klass  = nil

    if params.is_a?(Array)
      target = params.last                          # [:admin, Budget], [:admin, budget],
                                                    # [:admin, @budget], [:new, :admin, Budget]
    else
      target = params                               # component, @component, Component
    end

    if target.is_a?(ApplicationDecorator)
      klass = target.object.class                   # decorated instance
    elsif target.is_a?(ActiveRecord::Base)
      klass = target.class                          # undecorated instance
    else
      klass = target                                # class
    end

    if klass.ancestors.include?(InventoryRecord)
      klass = InventoryRecord
    end

    return klass

  end

  def get_icon(action, options, html_options)
    icon = html_options.delete(:icon)
    if icon.nil?
      # look for an 'a' param in the options which might be workflow
      # hint to the loan object (e.g. check_in, check_out, etc)
      if options[:a]
        icon = t("helpers.icons.#{ options[:a] }")
      else
        # just go with the action's default icon
        icon = t("helpers.icons.#{ action.to_s }")
      end
    end
    icon
  end

  def get_link_params(object, options = {}, html_options = {})
    action       = extract_action(object)
    class_name   = extract_class(object).name.underscore
    ability      = options.delete(:ability)
    path         = options.delete(:path)
    icon         = get_icon(action, options, html_options)
    hint         = html_options.delete(:hint)
    filter       = options[:filter]
    default_text = t("links.#{ class_name }.#{ action.to_s }",  default: :"helpers.actions.#{ action.to_s }")

    if filter
      default_text = t("filters.#{ class_name }.#{ filter.to_s }",  default: [:"links.#{ class_name }.#{ action.to_s }", :"helpers.actions.#{ action.to_s }"])
    elsif options[:a]
      default_text = t("links.#{ class_name }.#{ options[:a].to_s }", default: [:"links.#{ class_name }.#{ action.to_s }", :"helpers.actions.#{ action.to_s }"])
    end

    text = html_options.delete(:text) || default_text

    html_options[:class] ||= String.new
    if action == :index
      html_options[:class] << " auth-link collection"
    else
      html_options[:class] << " auth-link singular"
    end

    case action
    when :new
      options.reverse_merge!(action: object.shift)
      ability ||= :create
      hint = t("hints.new_#{ class_name }", default: strip_tags(text)) unless hint
    when :edit
      ability ||= :update
      hint = t("hints.edit_#{ class_name }", default: strip_tags(text)) unless hint
    when :index
      ability ||= :read
      if filter && filter.to_s != "all"
        hint = t("hints.show_all_#{ filter.to_s }_#{ class_name.pluralize }", default: strip_tags(text)) unless hint
      else
        hint = t("hints.show_all_#{ class_name.pluralize }", default: strip_tags(text)) unless hint
      end
    when :show
      ability ||= :read
      hint = t("hints.show_#{ class_name }", default: strip_tags(text)) unless hint
    else
      raise "unknown action: #{ action.inspect }"
    end

    path    ||= polymorphic_url(object, options)
    content   = "#{ icon } <span class='auth-link-text'>#{ text }</span>".squish.html_safe

    html_options.reverse_merge!({
        :rel         => "tooltip",
        :title       => hint,
        'data-delay' => 500
      })

    {
      :authorized   => can?(ability, object),
      :path         => path,
      :html_options => html_options,
      :content      => content
    }
  end

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
    url = url.slice(0..-2) if url.last == "?"
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
