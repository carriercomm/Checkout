class PartsController < ApplicationController

  before_filter :strip_brand, :only => [:create, :update, :destroy]

  # GET /parts
  # GET /parts.json
  def index
    if params["model_id"].present?
      @parts = Model.find(params["model_id"].to_i).parts.includes(:asset_tags).order("asset_tags.uid").page(params[:page])
    else
      @parts = Part.includes(:asset_tags).order("asset_tags.uid").page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @parts }
    end
  end

  # GET /parts/1
  # GET /parts/1.json
  def show
    @part = Part.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @part }
    end
  end

  # GET /admin/parts/new
  # GET /admin/parts/new.json
  def new
    @part = Part.new
    @part.model = Model.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @part }
    end
  end

  # GET /admin/parts/1/edit
  def edit
    @part = Part.find(params[:id])
  end

  # POST /admin/parts
  # POST /admin/parts.json
  def create
    @part = Part.new(params[:part])

    respond_to do |format|
      if @part.save
        format.html { redirect_to part_path(@part), notice: 'Part was successfully created.' }
        format.json { render json: @part, status: :created, location: @part }
      else
        format.html { render action: "new" }
        format.json { render json: @part.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/parts/1
  # PUT /admin/parts/1.json
  def update
    @part = Part.find(params[:id])

    respond_to do |format|
      if @part.update_attributes(params[:part])
        format.html { redirect_to part_path(@part), notice: 'Part was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @part.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/parts/1
  # DELETE /admin/parts/1.json
  def destroy
    @part = Part.find(params[:id])
    @part.destroy

    respond_to do |format|
      format.html { redirect_to parts_url }
      format.json { head :no_content }
    end
  end

  protected

  def strip_brand
    # throw away the brand, since its information is carried by the model
    model_attrs = !!params[:part] ? params[:part].delete(:model_attributes) : nil
  end

end
