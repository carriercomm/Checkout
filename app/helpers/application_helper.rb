module ApplicationHelper

  def active(path)
    (current_page? path) ? 'class="active"'.html_safe : ""
  end

  # TODO: ummm, this is clumsy. Like... no, really. It's actually embarrassing me.
  def sidebar_link(text, path, default_tooltip = "", condition = true, failure_tooltip = nil, options = {})
    # setup the base options for the tooltip
    link_opts = {
      :rel   => "tooltip",
      "data-placement" => "right"
    }

    li_opts = {}

    logger.debug "---root_path: " + root_path
    logger.debug "---path: " + path

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

end
