class SearchController < ApplicationController

  # GET /search.json
  def index
    results = []

    users = get_users(params["q"])
    results.concat(users.map(&:autocomplete_json))

    component_models = get_component_models(params["q"])
    results.concat(component_models.map(&:autocomplete_json))

    kits = get_kits(params["q"])
    results.concat(kits.map(&:autocomplete_json))

    respond_to do |format|
      format.json { render json: results }
    end
  end

  # def kit_jump
  #   results = []
  #   get_kits(params["k"])

  #   respond_to do |format|
  #     format.json { render json: results }
  #   end
  # end

  protected

  def get_users(q)
    if can? :read, User
      return User.search(q).limit(10).decorate
    end
  end

  def get_component_models(q)
    if can? :read, ComponentModel
      component_models = []
      if current_user.attendant?
        component_models = ComponentModel.search(q).limit(20).decorate
      elsif current_user.can_see_entire_circulating_inventory?
        component_models = ComponentModel.circulating.search(q).limit(20).decorate
      else
        component_models = ComponentModel.circulating_for_user(current_user).search(q).limit(20).decorate
      end
      return component_models
    end
  end

  def get_kits(q)
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
      return kits
    end
  end

end
