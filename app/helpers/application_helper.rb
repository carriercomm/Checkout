module ApplicationHelper

  def dropdown_for(name, &block)
    content_tag("li", :class=>"dropdown") do 
      link_to(raw("#{ name.html_safe }<b class=\"caret\"></b>"), "#", :class=>"dropdown-toggle", "data-toggle" =>"dropdown") +
      content_tag("ul", :class=>"dropdown-menu", &block)
    end
  end

end
