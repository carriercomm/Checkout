class SearchController < ApplicationController

  # GET /search.json
  def index
    q = params["q"]
    results = []

    if can? :read, User
      users  = User.search(q).limit(10).decorate
      results.concat(users.map(&:autocomplete_json).concat(results))
    end

    if can? :read, ComponentModel
      component_models = []

      if current_user.attendant?
        component_models = ComponentModel.search(q).limit(20).decorate
      elsif current_user.can_see_entire_circulating_inventory?
        component_models = ComponentModel.circulating.search(q).limit(20).decorate
      else
        component_models = ComponentModel.circulating_for_user(current_user).search(q).limit(20).decorate
      end

      results.concat(component_models.map(&:autocomplete_json))

    end

    if can? :read, Kit
      kits = []

      if current_user.attendant?
        kits.concat(Kit.asset_tag_search(q).limit(20).decorate)
        kits.concat(Kit.id_search(q).limit(20).decorate)
      elsif current_user.can_see_entire_circulating_inventory?
        kits.concat(Kit.circulating.asset_tag_search(q).limit(20).decorate)
        kits.concat(Kit.circulating.id_search(q).limit(20).decorate)
      else
        kits.concat(Kit.circulating_for_user(current_user).asset_tag_search(q).limit(20).decorate)
        kits.concat(Kit.circulating_for_user(current_user).id_search(q).limit(20).decorate)
      end
      kits.uniq!
      results.concat(kits.map { |k| k.autocomplete_json(q: q) })
    end

    respond_to do |format|
      format.json { render json: results }
    end
  end

end
