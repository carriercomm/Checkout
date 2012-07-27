class ReservationsController < ApplicationController

  # GET /reservations
  # GET /reservations.json
  def index
    if params[:user_id].present?
      @reservations = User.find(params[:user_id]).reservations.order("reservations.start_at DESC").page(params[:page])
    elsif params[:kit_id].present?
      @reservations = Kit.find(params[:kit_id]).reservations.order("reservations.start_at DESC").page(params[:page])
    else
      @reservations = Reservation.order("reservations.start_at DESC").page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /reservations/1
  # GET /reservations/1.json
  def show
    @reservation = Reservation.find(params[:id])
    @client      = @reservation.client
    @kit         = @reservation.kit
    @location    = @kit.location

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /reservations/new
  # GET /reservations/new.json
  def new
    @client = (params[:user_id]) ? User.find(params[:user_id]) : current_user

    # do we have a specific kit to check out?
    if params[:kit_id].present?
      @kit         = Kit.includes(:location, :model => :brand).find(params[:kit_id])
      @reservation = @client.reservations.build(:kit_id => @kit.id)
      @locations   = [@kit.location]

      # setup javascript data structures to make the date picker work
      # TODO: move this to a model method on kit (same as implemented for Model)
      setup_kit_checkout_days(@kit)

    # do we have a general model to check out?
    elsif params[:model_id].present?
      @reservation = @client.reservations.build
      @model       = Model.checkoutable.includes(:kits => :location).find(params[:model_id])
      @locations   = (@model.kits.collect { |k| k.location }).uniq
      gon.locations = @model.checkout_days_json

    else
      flash[:error] = "Start by finding something to check out!"
      redirect_to models_path and return
    end

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /reservations/1/edit
  def edit
    @reservation = Reservation.find(params[:id])
    @kit         = @reservation.kit
    setup_kit_checkout_days(@kit)
  end

  # POST /reservations
  # POST /reservations.json
  def create
    @reservation = Reservation.new(params[:reservation])

    respond_to do |format|
      if @reservation.save
        format.html { redirect_to @reservation, notice: 'Reservation was successfully created.' }
      else
        format.html { render action: "new" }
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
      else
        set_open_days
        format.html { render action: "edit" }
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

  private

  # gather the available checkout days for the kit and format for
  # datepicker consumption
  def setup_kit_checkout_days(kit)
    gon.locations = {
      kit.location.id => {
        'kits' => [{
                     'kit_id' => kit.id,
                     'days_reservable' => kit.days_reservable
                   }]
      }
    }
  end

end
