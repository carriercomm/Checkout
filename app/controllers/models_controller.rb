class ModelsController < ApplicationController
  # GET /models
  # GET /models.json
  def index
    @models = Model
    apply_scopes_and_pagination

    respond_to do |format|
      format.html
    end
  end

  def checkoutable
    @models = Model.checkoutable
    apply_scopes_and_pagination

    respond_to do |format|
      format.html { render :action => 'index' }
    end
  end

  # GET /models/1
  # GET /models/1.json
  def show
    @model = Model.includes(:kits).find(params[:id])

    respond_to do |format|
      format.html
    end
  end

  # GET /models/new
  # GET /models/new.json
  def new
    @model = Model.new

    respond_to do |format|
      format.html
    end
  end

  # GET /models/1/edit
  def edit
    @model = Model.find(params[:id])
  end

  # POST /models
  # POST /models.json
  def create
    @model = Model.new(params[:model])

    respond_to do |format|
      if @model.save
        format.html { redirect_to @model, notice: 'Model was successfully created.' }
        # format.json { render json: @model, status: :created, location: @model }
      else
        format.html { render action: "new" }
        # format.json { render json: @model.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /models/1
  # PUT /models/1.json
  def update
    @model = Model.find(params[:id])

    respond_to do |format|
      if @model.update_attributes(params[:model])
        format.html { redirect_to @model, notice: 'Model was successfully updated.' }
        # format.json { head :no_content }
      else
        format.html { render action: "edit" }
        # format.json { render json: @model.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /models/1
  # DELETE /models/1.json
  def destroy
    @model = Model.find(params[:id])
    @model.destroy

    respond_to do |format|
      format.html { redirect_to models_url }
      # format.json { head :no_content }
    end
  end

  private

  def apply_scopes_and_pagination
    scope_by_brand
    scope_by_category

    @models = @models.joins(:brand).order("brands.name, models.name").page(params[:page])
  end

  def scope_by_brand
    @models = @models.brand(params["brand_id"]) if params["brand_id"].present?
  end

  def scope_by_category
    @models = @models.category(params["category_id"]) if params["category_id"].present?
  end
end

