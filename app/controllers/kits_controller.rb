class KitsController < ApplicationController

  # use CanCan to authorize this resource
  authorize_resource

  decorates_assigned :budgets
  decorates_assigned :kit
  decorates_assigned :kits


  # GET /kits
  # GET /kits.json
  def index
    @kits = Kit
    apply_scopes_and_pagination

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @kits }
    end
  end

  # TODO: add a group params contraint to this query - a la the
  #       select2 method in users_controller.
  # TODO: move this logic into a separate model or query object
  # GET /kits/select2.json
  def select2
    # find things by asset tag
    asset_tags = Kit.asset_tag_search(params["q"])

    # find things by the kit id
    ids = Kit.id_search(params["q"])

    # calculate the totals for the select2 widget
    total = asset_tags.count + ids.count

    # actually do the query, and concatenate the results
    kits = [asset_tags.limit(10).decorate, ids.limit(10).decorate].flatten

    respond_to do |format|
      #format.html # index.html.erb
      format.json { render json: { items: kits.map(&:select2_json), total: total} }
    end
  end

  # GET /kits/1
  # GET /kits/1.json
  def show
    # TODO: extract this out into a query object
    @kit = Kit.joins(:location, :components, :component_models => :brand)
      .includes([:location, { :components => [ :inventory_details, :budget ]}, {:component_models => :brand}])
      .order("components.position ASC")
      .find(params[:id])

    respond_to do |format|
      format.html { render layout: 'sidebar' } # show.html.erb
      # format.json { render json: @kit }
    end
  end

  # GET /kits/new
  # GET /kits/new.json
  def new
    @kit = Kit.new
    @kit.persist_workflow_state('non_circulating')
    @kit.components.build
    @budgets = Budget.active
    @circulation_types = Kit.workflow_spec.state_names

    respond_to do |format|
      format.html # new.html.erb
      # format.json { render json: @kit }
    end
  end

  # GET /kits/1/edit
  def edit
    @kit = Kit.find(params[:id])
    @budgets = Budget.active
    @circulation_types = Kit.workflow_spec.state_names
  end

  # POST /kits
  # POST /kits.json
  def create
    username = params[:kit].delete(:custodian)
    @kit = Kit.new(params[:kit])
    if username
      @kit.custodian = User.find_by_username(username)
    end

    respond_to do |format|
      if @kit.save
        format.html { redirect_to @kit, notice: 'Kit was successfully created.' }
        # format.json { render json: @kit, status: :created, location: @kit }
      else
        format.html { render action: "new" }
        # format.json { render json: @kit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /kits/1
  # PUT /kits/1.json
  def update
    @kit = Kit.find(params[:id])
    if username = params[:kit].delete(:custodian)
      # TODO: fix this so it raises an error when no user is found
      @kit.custodian = User.find_by_username(username)
    end

    respond_to do |format|
      kit_updated = @kit.update_attributes(params[:kit])

      if kit_updated
        format.html { redirect_to @kit, notice: 'Kit was successfully updated.' }
        # format.json { head :no_content }
      else
        format.html { render action: "edit" }
        # format.json { render json: @kit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kits/1
  # DELETE /kits/1.json
  def destroy
    @kit = Kit.find(params[:id])
    @kit.destroy

    respond_to do |format|
      format.html { redirect_to kits_url }
      # format.json { head :no_content }
    end
  end

  private

  def apply_scopes_and_pagination
    scope_by_filter_params
    scope_by_user
    scope_by_brand
    #scope_by_budget
    scope_by_category
    scope_by_component_model

    @kits = @kits.joins(:component_models => :brand)
      .order("kits.id")
      .page(params[:page])
  end

  def scope_by_user
    if current_user.attendant?
      # no limits
    elsif current_user.can_see_entire_circulating_inventory?
      # no non-circulating kits
      @kits = @kits.with_circulating_state
    else
      # only circulating kits in the user's group
      @kits = @kits.circulating_for_user(current_user)
    end
  end

  def scope_by_filter_params
    @filter = params["filter"] || "all"
    case @filter
    when "circulating"        then @kits = @kits.with_circulating_state
    when "missing_components" then @kits = @kits.with_missing_components
    when "non_circulating"    then @kits = @kits.with_non_circulating_state
    when "deaccessioned"      then @kits = @kits.with_deaccessioned_state
    end
  end

  # TODO: does this make any sense? this might need to be fixed to
  #       work with multiple brands in a kit
  def scope_by_brand
    @kits = @kits.brand(params["brand_id"]) if params["brand_id"].present?
  end

  def scope_by_component_model
    @kits = @kits.where("component_models.id = ?", params["component_model_id"].to_i) if params["component_model_id"].present?
  end

  # TODO: restore this functionality?
  # def scope_by_budget
  #   @kits = @kits.where(budget_id: params["budget_id"]) if params["budget_id"].present?
  # end

  def scope_by_category
    @kits = @kits.category(params["category_id"]) if params["category_id"].present?
  end
end
