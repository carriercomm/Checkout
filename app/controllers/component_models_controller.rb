class ComponentModelsController < ApplicationController

  # use CanCan to authorize this resource, we have to do it manually
  # due to some weird routing/resource issue I can't figure out
  before_filter :authorize_read, :only => [:index, :show]
  before_filter :authorize_manage, :only => [:new, :create, :edit, :update, :destroy]

  # GET /models
  # GET /models.json
  def index
    @component_models = ComponentModel
    apply_scopes

    # get a total (used by the select2 widget) before we apply pagination
    @total  = @component_models.count

    apply_pagination

    @component_models = ComponentModelDecorator.decorate(@component_models)

    respond_to do |format|
      format.html
      format.json { render json: { items: @component_models.map(&:select2_json), total: @total} }
    end
  end

  # TODO: add query param to constrain search to component_models which require training
  # GET /component_models/select2.json
  def select2
    # find by name
    component_models = ComponentModel.search(params["q"])
    component_models = ComponentModelDecorator.decorate(component_models)

    respond_to do |format|
      #format.html # index.html.erb
      format.json { render json: { items: component_models.map(&:select2_json)} }
    end
  end

  # TODO: move this view to the sidebar layout
  # GET /models/1
  # GET /models/1.json
  def show
    @component_model = ComponentModel.includes(:kits => [:location]).find(params[:id])
    @trainings       = @component_model.trainings.includes(:user).where("users.disabled = ?", false).order("users.username")
    @component_model = ComponentModelDecorator.decorate(@component_model)
    @trainings       = TrainingDecorator.decorate(@trainings)

    respond_to do |format|
      format.html { render layout: 'sidebar' } # show.html.erb
    end
  end

  # GET /models/new
  # GET /models/new.json
  def new
    @component_model = ComponentModel.new
    @component_model = ComponentModelDecorator.decorate(@component_model)
    @component_model.brand = Brand.find_by_name("Generic")

    respond_to do |format|
      format.html
    end
  end

  # GET /models/1/edit
  def edit
    @component_model = ComponentModelDecorator.find(params[:id])
    @trainings       = @component_model.model.trainings.includes(:user).where("users.disabled = ?", false).order("users.username")
  end

  # POST /models
  # POST /models.json
  def create
    @component_model = ComponentModel.new(params[:component_model])
    @component_model = ComponentModelDecorator.decorate(@component_model)

    respond_to do |format|
      if @component_model.save
        format.html { redirect_to @component_model, notice: 'Model was successfully created.' }
        # format.json { render json: @component_model, status: :created, location: @component_model }
      else
        format.html { render action: "new" }
        # format.json { render json: @component_model.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /models/1
  # PUT /models/1.json
  def update
    @component_model = ComponentModelDecorator.find(params[:id])

    respond_to do |format|
      if @component_model.update_attributes(params[:component_model])
        format.html { redirect_to @component_model, notice: 'Model was successfully updated.' }
        # format.json { head :no_content }
      else
        format.html { render action: "edit" }
        # format.json { render json: @component_model.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /models/1
  # DELETE /models/1.json
  def destroy
    @component_model = ComponentModel.find(params[:id])
    @component_model.destroy

    respond_to do |format|
      format.html { redirect_to component_models_url }
      # format.json { head :no_content }
    end
  end

  private

  def apply_scopes
    @component_models = @component_models.joins(:brand).includes(:brand).order("brands.name, component_models.name")
    scope_by_filter_params
    scope_by_brand
    scope_by_category
    scope_by_search_params
  end

  def apply_pagination
    @component_models = @component_models.page(params[:page]).per(params[:page_limit])
  end

  # def apply_scopes_and_pagination
  #   apply_scopes
  #   apply_pagination
  # end

  def authorize_manage
    authorize! :manage, ComponentModel
  end

  def authorize_read
    authorize! :read, ComponentModel
  end

  def scope_by_filter_params
    case params[:filter]
    when "checkoutable"     then @component_models = @component_models.checkoutable
    end
  end

  def scope_by_brand
    @component_models = @component_models.brand(params["brand_id"]) if params["brand_id"].present?
  end

  def scope_by_category
    @component_models = @component_models.category(params["category_id"]) if params["category_id"].present?
  end

  def scope_by_search_params
    if params["q"].present?
      query = "%#{ ComponentModel.normalize(params["q"]) }%"
      @component_models = @component_models.where("component_models.autocomplete LIKE ?", query)
    end
  end
end

