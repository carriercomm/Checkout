class ReservationsController < ApplicationController

  # GET /reservations
  # GET /reservations.json
  def index
    @reservations = Reservation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @reservations }
    end
  end

  # GET /reservations/1
  # GET /reservations/1.json
  def show
    @reservation = Reservation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @reservation }
    end
  end

  # GET /reservations/new
  # GET /reservations/new.json
  def new
    @user = (params[:user_id]) ? User.find(params[:user_id]) : current_user
    
    if params[:kit_id].present?
      # we have a specific kit to check out
      @reservation = @user.reservations.build(:kit_id => params[:kit_id])

      # gather the available checkout days for the kit
      gon.days_open = @reservation.kit.location.open_days

    # do we have a general model to check out?
    elsif params[:model_id].present?
      @reservation = @user.reservations.build
      @model       = Model.find(params[:model_id])
#      @reservation = Model.find(params[:model_id].)

    else
      flash[:error] = "Start by finding something to check out!"
      redirect_to models_path and return
    end


    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @reservation }
    end
  end

  # GET /reservations/1/edit
  def edit
    @reservation = Reservation.find(params[:id])

    gon.days_open = @reservation.kit.location.open_days

  end

  # POST /reservations
  # POST /reservations.json
  def create
    @reservation = Reservation.new(params[:reservation])

    respond_to do |format|
      if @reservation.save
        format.html { redirect_to @reservation, notice: 'Reservation was successfully created.' }
        format.json { render json: @reservation, status: :created, location: @reservation }
      else
        logger.debug "----" + @reservation.errors.inspect
        # FIXME: set_open_days

        format.html { render action: "new" }
        format.json { render json: @reservation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /reservations/1
  # PUT /reservations/1.json
  def update
    @reservation = Reservation.find(params[:id])

    respond_to do |format|
      if @reservation.update_attributes(params[:reservation])
        format.html { redirect_to @reservation, notice: 'Reservation was successfully updated.' }
        format.json { head :no_content }
      else
        set_open_days
        format.html { render action: "edit" }
        format.json { render json: @reservation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reservations/1
  # DELETE /reservations/1.json
  def destroy
    @reservation = Reservation.find(params[:id])
    @reservation.destroy

    respond_to do |format|
      format.html { redirect_to reservations_url }
      format.json { head :no_content }
    end
  end

end
