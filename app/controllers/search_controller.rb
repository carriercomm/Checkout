class SearchController < ApplicationController

  # GET /search.json
  def index
    q = params["q"]

    models = ModelDecorator.decorate(Model.search(q, 20))
    kits   = KitDecorator.decorate(Kit.asset_tag_search(q, 20))

    results = models.map(&:autocomplete_json)
    results.concat kits.map { |k| k.autocomplete_json(q: q) }

    # check if this user should be able to search over usernames
    if current_user.has_role? "admin"
      users  = UserDecorator.decorate(User.username_search(q, 10))
      results = users.map(&:autocomplete_json).concat(results)
    end

    respond_to do |format|
      format.json { render json: results }
    end
  end

end
