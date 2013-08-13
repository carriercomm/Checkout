class BrandsController < ApplicationController

  # use CanCan to authorize this resource
  authorize_resource

  # GET /brands
  # GET /brands.json
  def index
    @brands = Brand
    apply_scopes

    # get a total (used by the select2 widget) before we apply pagination
    @total  = @brands.count

    apply_pagination

    @brands = @brands.decorate

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: { items: @brands.map(&:model), total: @total} }
    end
  end

  # TODO: is this being used? move it to a collection route on the index action
  def circulating
    @brands = Brand.order("brands.name ASC")
      .having_circulating_kits
      .page(params[:page])
      .decorate

    respond_to do |format|
      format.html { render :action => 'index' }
      # format.json { render json: @brands }
    end
  end

  # GET /brands/1
  # GET /brands/1.json
  def show
    @brand = Brand.includes(:component_models)
      .find(params[:id])
      .decorate

    respond_to do |format|
      format.html # show.html.erb
      # format.json { render json: @brand }
    end
  end

  # GET /brands/new
  # GET /brands/new.json
  def new
    @brand = Brand.new.decorate

    respond_to do |format|
      format.html # new.html.erb
      # format.json { render json: @brand }
    end
  end

  # GET /brands/1/edit
  def edit
    @brand = Brand.find(params[:id]).decorate
  end

  # POST /brands
  # POST /brands.json
  def create
    @brand = Brand.new(params[:brand])

    respond_to do |format|
      if @brand.save
        @brand = @brand.decorate
        format.html { redirect_to @brand, notice: 'Brand was successfully created.' }
        format.json { render json: @brand, status: :created, location: @brand }
      else
        format.html { render action: "new" }
        format.json { render json: @brand.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /brands/1
  # PUT /brands/1.json
  def update
    @brand = Brand.find(params[:id])

    respond_to do |format|
      if @brand.update_attributes(params[:brand])
        @brand = @brand.decorate
        format.html { redirect_to @brand, notice: 'Brand was successfully updated.' }
        # format.json { head :no_content }
      else
        @brand = @brand.decorate
        format.html { render action: "edit" }
        # format.json { render json: @brand.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /brands/1
  # DELETE /brands/1.json
  def destroy
    @brand = Brand.find(params[:id])
    @brand.destroy

    respond_to do |format|
      format.html { redirect_to brands_url }
      # format.json { head :no_content }
    end
  end

  private

  def apply_scopes
    @brands = @brands.includes(:component_models).order("brands.name ASC")
    scope_by_brand
    scope_by_category
    scope_by_search_params
    scope_by_filter_params
  end

  def apply_pagination
    @brands = @brands.page(params[:page]).per(params[:page_limit])
  end

  def apply_scopes_and_pagination
    apply_scopes
    apply_pagination
  end

  def scope_by_brand
    @brands = @brands.brand(params["brand_id"]) if params["brand_id"].present?
  end

  def scope_by_category
    @brands = @brands.category(params["category_id"]) if params["category_id"].present?
  end

  def scope_by_filter_params
    case params[:filter]
    when "circulating"     then @brands = @brands.having_circulating_kits
    when "non_circulating" then @brands = @brands.not_having_circulating_kits
    end
  end

  def scope_by_search_params
    if params["q"].present?
      query = "%#{params["q"]}%"
      @brands = @brands.where("brands.name ILIKE ?", query)
    end
  end

end
