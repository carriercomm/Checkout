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

  # this mainly here to keep definition lists from breaking when a
  # value is empty
  def something(val)
    if val.is_a? TrueClass
      return "Yes"
    elsif val.is_a? FalseClass
      return "No" 
    else
      return val || raw("&nbsp;")
    end
  end
end
