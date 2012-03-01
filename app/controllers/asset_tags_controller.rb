class AssetTagsController < ApplicationController
  # GET /asset_tags
  # GET /asset_tags.json
  def index
    @asset_tags = AssetTag.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @asset_tags }
    end
  end

  # GET /asset_tags/1
  # GET /asset_tags/1.json
  def show
    @asset_tag = AssetTag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @asset_tag }
    end
  end

  # GET /asset_tags/new
  # GET /asset_tags/new.json
  def new
    @asset_tag = AssetTag.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @asset_tag }
    end
  end

  # GET /asset_tags/1/edit
  def edit
    @asset_tag = AssetTag.find(params[:id])
  end

  # POST /asset_tags
  # POST /asset_tags.json
  def create
    @asset_tag = AssetTag.new(params[:asset_tag])

    respond_to do |format|
      if @asset_tag.save
        format.html { redirect_to @asset_tag, notice: 'Asset tag was successfully created.' }
        format.json { render json: @asset_tag, status: :created, location: @asset_tag }
      else
        format.html { render action: "new" }
        format.json { render json: @asset_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /asset_tags/1
  # PUT /asset_tags/1.json
  def update
    @asset_tag = AssetTag.find(params[:id])

    respond_to do |format|
      if @asset_tag.update_attributes(params[:asset_tag])
        format.html { redirect_to @asset_tag, notice: 'Asset tag was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @asset_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /asset_tags/1
  # DELETE /asset_tags/1.json
  def destroy
    @asset_tag = AssetTag.find(params[:id])
    @asset_tag.destroy

    respond_to do |format|
      format.html { redirect_to asset_tags_url }
      format.json { head :no_content }
    end
  end
end

