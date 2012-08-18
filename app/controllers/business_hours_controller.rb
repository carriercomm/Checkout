class BusinessHoursController < ApplicationController

  authorize_resource

  # GET /business_hours
  # GET /business_hours.json
  def index
    @business_hours = BusinessHour.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /business_hours/1
  # GET /business_hours/1.json
  def show
    @business_hour = BusinessHour.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /business_hours/new
  # GET /business_hours/new.json
  def new
    # @business_hour = BusinessHour.new

    respond_to do |format|
      format.html # new.html.erb
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
        format.html { redirect_to @business_hour, :notice => 'Business hour was successfully created.' }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /business_hours/1
  # PUT /business_hours/1.json
  def update
    @business_hour = BusinessHour.find(params[:id])

    respond_to do |format|
      if @business_hour.update_attributes(params[:business_hour])
        format.html { redirect_to @business_hour, :notice => 'Business hour was successfully updated.' }
      else
        format.html { render :action => "edit" }
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
    end
  end
end
