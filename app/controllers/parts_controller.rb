class PartsController < ApplicationController
  # GET /parts
  # GET /parts.json
  def index
    if params["model_id"].present?
      @parts = Model.find(params["model_id"].to_i).parts.order("name ASC").page(params[:page])
    else
      @parts = Part.page(params[:page])
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

end

