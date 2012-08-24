class ComponentsController < ApplicationController

  # use CanCan to authorize this resource
  authorize_resource
  before_filter :strip_brand, :only => [:create, :update, :destroy]

  # GET /components
  # GET /components.json
  def index
    if params["kit_id"].present?
      @components = Kit.find(params["kit_id"].to_i).components.includes(:asset_tags).order("asset_tags.uid").page(params[:page])
    else
      @components = Component.includes(:asset_tags).order("asset_tags.uid").page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @components }
    end
  end

  # GET /components/1
  # GET /components/1.json
  def show
    @component = Component.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @component }
    end
  end

  # GET /admin/components/new
  # GET /admin/components/new.json
  def new
    @component = Component.new
    @component.model = Model.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @component }
    end
  end

  # GET /admin/components/1/edit
  def edit
    @component = Component.find(params[:id])
  end

  # POST /admin/components
  # POST /admin/components.json
  def create
    @component = Component.new(params[:component])

    respond_to do |format|
      if @component.save
        format.html { redirect_to component_path(@component), notice: 'Component was successfully created.' }
        format.json { render json: @component, status: :created, location: @component }
      else
        format.html { render action: "new" }
        format.json { render json: @component.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/components/1
  # PUT /admin/components/1.json
  def update
    @component = Component.find(params[:id])

    respond_to do |format|
      if @component.update_attributes(params[:component])
        format.html { redirect_to component_path(@component), notice: 'Component was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @component.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/components/1
  # DELETE /admin/components/1.json
  def destroy
    @component = Component.find(params[:id])
    @component.destroy

    respond_to do |format|
      format.html { redirect_to components_url }
      format.json { head :no_content }
    end
  end

  protected

  def strip_brand
    # throw away the brand, since its information is carried by the model
    model_attrs = !!params[:component] ? params[:component].delete(:model_attributes) : nil
  end

end
