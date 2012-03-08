class BusinessHoursController < ApplicationController
  # GET /business_hours
  # GET /business_hours.json
  def index
    @business_hours = BusinessHour.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @business_hours }
    end
  end

  # GET /business_hours/1
  # GET /business_hours/1.json
  def show
    @business_hour = BusinessHour.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @business_hour }
    end
  end

  # GET /business_hours/new
  # GET /business_hours/new.json
  def new
    # @business_hour = BusinessHour.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @business_hour }
    end
  end

  # GET /business_hours/1/edit
  def edit
    @business_hour = BusinessHour.find(params[:id])
  end

  # POST /business_hours
  # POST /business_hours.json
  def create
    @business_hour = BusinessHour.new(params[:business_hour])

    respond_to do |format|
      if @business_hour.save
        format.html { redirect_to @business_hour, notice: 'Business hour was successfully created.' }
        format.json { render json: @business_hour, status: :created, location: @business_hour }
      else
        format.html { render action: "new" }
        format.json { render json: @business_hour.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /business_hours/1
  # PUT /business_hours/1.json
  def update
    @business_hour = BusinessHour.find(params[:id])

    respond_to do |format|
      if @business_hour.update_attributes(params[:business_hour])
        format.html { redirect_to @business_hour, notice: 'Business hour was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @business_hour.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /business_hours/1
  # DELETE /business_hours/1.json
  def destroy
    @business_hour = BusinessHour.find(params[:id])
    @business_hour.destroy

    respond_to do |format|
      format.html { redirect_to business_hours_url }
      format.json { head :no_content }
    end
  end
end
