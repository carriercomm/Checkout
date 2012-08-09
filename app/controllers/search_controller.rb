class SearchController < ApplicationController

  # GET /search.json
  def index
    q = params["q"]

    models = ModelDecorator.decorate(Model.search(q, 20))
    kits   = KitDecorator.decorate(Kit.asset_tag_search(q, 20))

    results = models.collect { |m| m.as_json }
    results.concat kits.collect { |k| k.as_json(q: q) }

    respond_to do |format|
      format.json { render json: results }
    end
  end

end
