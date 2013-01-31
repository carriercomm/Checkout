class CovenantsController < ApplicationController

  # use CanCan to authorize this resource
  authorize_resource

  # GET /covenants
  # GET /covenants.json
  def index
    @covenants = Covenant.page(params[:page])
      .per(params[:page_limit])
      .decorate

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @covenants }
    end
  end

  # GET /covenants/1
  # GET /covenants/1.json
  def show
    @covenant = Covenant.find(params[:id]).decorate

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @covenant }
    end
  end

  # GET /covenants/new
  # GET /covenants/new.json
  def new
    @covenant = Covenant.new.decorate

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @covenant }
    end
  end

  # GET /covenants/1/edit
  def edit
    @covenant = Covenant.find(params[:id]).decorate
  end

  # POST /covenants
  # POST /covenants.json
  def create
    @covenant = Covenant.new(params[:covenant])

    respond_to do |format|
      if @covenant.save
        @covenant = @covenant.decorate
        format.html { redirect_to @covenant, notice: 'Covenant was successfully created.' }
        format.json { render json: @covenant, status: :created, location: @covenant }
      else
        format.html { render action: "new" }
        format.json { render json: @covenant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /covenants/1
  # PUT /covenants/1.json
  def update
    @covenant = Covenant.find(params[:id])

    respond_to do |format|
      if @covenant.update_attributes(params[:covenant])
        @covenant = @covenant.decorate
        format.html { redirect_to @covenant, notice: 'Covenant was successfully updated.' }
        format.json { head :no_content }
      else
        @covenant = @covenant.decorate
        format.html { render action: "edit" }
        format.json { render json: @covenant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /covenants/1
  # DELETE /covenants/1.json
  def destroy
    @covenant = Covenant.find(params[:id])
    @covenant.destroy

    respond_to do |format|
      format.html { redirect_to covenants_url }
      format.json { head :no_content }
    end
  end
end
