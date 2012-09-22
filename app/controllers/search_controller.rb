class SearchController < ApplicationController

  # GET /search.json
  def index
    q = params["q"]
    results = []

    if can? :read, User
      users  = UserDecorator.decorate(User.username_search(q).limit(10))
      results.concat(users.map(&:autocomplete_json).concat(results))
    end

    if can? :read, ComponentModel
      component_models = ComponentModelDecorator.decorate(ComponentModel.search(q, 20))
      results.concat(component_models.map(&:autocomplete_json))
    end

    if can? :read, Kit
      kits = KitDecorator.decorate(Kit.asset_tag_search(q).limit(20))
      results.concat(kits.map { |k| k.autocomplete_json(q: q) })
    end

    respond_to do |format|
      format.json { render json: results }
    end
  end

end
