class SearchController < ApplicationController

  # GET /search.json
  def index
    q = params["q"]
    results = []

    if can? :read, User
      users  = User.username_search(q).limit(10).decorate
      results.concat(users.map(&:autocomplete_json).concat(results))
    end

    if can? :read, ComponentModel
      component_models = ComponentModel.search(q, 20).decorate
      results.concat(component_models.map(&:autocomplete_json))
    end

    if can? :read, Kit
      kits = Kit.asset_tag_search(q).limit(20).decorate
      kits.concat(Kit.id_search(q).limit(20).decorate)
      kits.uniq!
      results.concat(kits.map { |k| k.autocomplete_json(q: q) })
    end

    respond_to do |format|
      format.json { render json: results }
    end
  end

end
