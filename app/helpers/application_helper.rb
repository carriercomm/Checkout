module ApplicationHelper

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

  # TODO: delete this 'something' method - its spirit has been subsumed by decorators
  def something(val)
    if val.is_a? TrueClass
      return "Yes"
    elsif val.is_a? FalseClass
      return "No"
    else
      return val || raw("&nbsp;")
    end
  end

  def sortable(column, title)
    title ||= column.titleize
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
    link_to(title, :sort => column, :direction => direction)
  end

  deprecate :something

end
