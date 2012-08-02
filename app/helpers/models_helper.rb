module ModelsHelper

  def category_links(category_collection)
    category_collection.collect! { |c| link_to(c.to_s, category_path(c)) }
    raw(category_collection.join(", "))
  end

end
