class KitsController < ApplicationController

  # use CanCan to authorize this resource
  authorize_resource

  # GET /kits
  # GET /kits.json
  def index
    @kits = Kit
    apply_scopes_and_pagination
    @kits = KitDecorator.decorate(@kits)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @kits }
    end
  end

  # TODO: add a group params contraint to this query - a la the
  #       select2 method in users_controller.
  # GET /kits/select2.json
  def select2
    kits   = Kit.asset_tag_search(params["q"])
    total  = kits.count
    kits   = KitDecorator.decorate(kits.limit(20))
    respond_to do |format|
      #format.html # index.html.erb
      format.json { render json: { items: kits.map(&:select2_json), total: total} }
    end
  end

  # GET /kits/1
  # GET /kits/1.json
  def show
    @kit = Kit.joins(:location, :budget, :components, :component_models => :brand)
              .includes(:location, :budget, :components, :component_models => :brand)
              .order("components.position ASC")
              .find(params[:id])

    @kit = KitDecorator.decorate(@kit)

    respond_to do |format|
      format.html # show.html.erb
      # format.json { render json: @kit }
    end
  end

  # GET /kits/new
  # GET /kits/new.json
  def new
    @kit = Kit.new
    @kit.components.build

    respond_to do |format|
      format.html # new.html.erb
      # format.json { render json: @kit }
    end
  end

  # GET /kits/1/edit
  def edit
    @kit = Kit.find(params[:id])
  end

  # POST /kits
  # POST /kits.json
  def create
    @kit = Kit.new(params[:kit])

    respond_to do |format|
      kit_saved = @kit.save

      if @kit.forced_not_checkoutable
        flash[:warning] = "Kit cannot be tombstoned and checkoutable, so it was forced to be non-checkoutable."
      end

      if kit_saved
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

    respond_to do |format|
      kit_updated = @kit.update_attributes(params[:kit])

      if @kit.forced_not_checkoutable
        flash[:warning] = "Kit cannot be tombstoned and checkoutable, so it was forced to be non-checkoutable."
      end

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
    scope_by_brand
    scope_by_budget
    scope_by_category
    @kits = @kits.joins(:component_models => :brand).order("brands.name, component_models.name").page(params[:page])
  end

  def scope_by_filter_params
    case params["filter"]
    when "checkoutable"       then @kits = @kits.checkoutable
    when "missing_components" then @kits = @kits.missing_components
    when "non_checkoutable"   then @kits = @kits.non_checkoutable
    when "tombstoned"         then @kits = @kits.tombstoned
    end
  end

  # TODO: does this make any sense? this might need to be fixed to
  #       work with multiple brands in a kit
  def scope_by_brand
    @kits = @kits.brand(params["brand_id"]) if params["brand_id"].present?
  end

  def scope_by_budget
    @kits = @kits.where(budget_id: params["budget_id"]) if params["budget_id"].present?
  end

  def scope_by_category
    @kits = @kits.category(params["category_id"]) if params["category_id"].present?
  end
end
