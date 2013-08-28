class LoansController < ApplicationController

  # use CanCan to authorize this resource
  authorize_resource

  decorates_assigned :loan
  decorates_assigned :loans

  before_filter :set_default_checkout_length

  # GET /loans
  # GET /loans.json
  def index
    @forward_params = {}

    if params[:user_id].present?
      @loans = User.find(params[:user_id]).loans

      # keep track of some params we want to use in the view to construct urls
      @forward_params[:user_id] = params[:user_id]
    elsif params[:kit_id].present?
      @loans = Kit.find(params[:kit_id]).loans

      # keep track of some params we want to use in the view to construct urls
      @forward_params[:kit_id] = params[:kit_id]
    else
      @loans = Loan
    end

    if params[:filter]
      case params[:filter]
      when "pending"     then @loans = @loans.where("loans.state = 'pending'")
      when "approved"    then @loans = @loans.where("loans.state = 'approved'")
      when "checked_out" then @loans = @loans.where("loans.state = 'checked_out'")
      when "checked_in"  then @loans = @loans.where("loans.state = 'checked_in'")
      when "rejected"    then @loans = @loans.where("loans.state = 'rejected'")
      when "canceled"    then @loans = @loans.where("loans.state = 'canceled'")
#      when "archived"    then @loans = @loans.where("loans.in_at IS NOT NULL OR ")
      end
    end

    @loans = @loans.order("loans.starts_at DESC").page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /loans/1
  # GET /loans/1.json
  def show
    @loan = Loan.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /loans/new
  # GET /loans/new.json
  def new
    # do we have a specific kit to check out?
    if params[:kit_id].present?
      kit       = Kit.find(params[:kit_id])
      starts_at = Time.zone.now
      client    = nil

      if params["event"].nil? || params["event"] == "reserve"
        client    = (params[:user_id]) ? User.find(params[:user_id]) : current_user
        starts_at = kit.location.next_time_open
      end

      @loan = Loan.new(kit: kit, starts_at: starts_at, client: client)

      # setup javascript data structures to make the date picker work
      gon.pickup_dates = kit.pickup_times_for_datepicker

    # do we have a general component_model to check out?
    # elsif params[:component_model_id].present?
    #   @component_model = ComponentModel.find(params[:component_model_id]).decorate
    #   @kits            = component_model.kits

    #   # setup javascript data structures to make the date picker work
    #   gon.locations = @component_model.locations_with_dates_circulating_for_datepicker
    #   format.html { render :kit_select } and return
    else
      flash[:error] = "Start by finding something to check out!"
      redirect_to component_models_path and return
    end

    # stuff the default checkout length into the gon object if it's available
    @default_checkout_length = Settings.default_checkout_length
    gon.default_checkout_length = @default_checkout_length

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /loans/1/edit
  def edit
    @loan = Loan.find(params[:id])
    # stuff the default checkout length into the gon object if it's available
    @default_checkout_length = Settings.default_checkout_length
    gon.default_checkout_length = @default_checkout_length

    gon.locations = @loan.kit.location_and_availability_record_for_datepicker(90, @loan)
  end

  # POST /loans
  # POST /loans.json
  def create
    @loan = Loan.new(params[:loan])

    respond_to do |format|
      if @loan.kit.nil? && @loan.component_model && @loan.location && @loan.starts_at && @loan.ends_at
        @kits = KitDecorator.decorate(@loan.available_circulating_kits)
        format.html { render :kit_select }
      elsif @loan.save
        if @loan.pending?
          flash[:error] = "Your reservation requires approval to be checked out for an extended period."
        end
        format.html { redirect_to @loan, notice: 'Loan was successfully created.' }
      else
        logger.debug @loan.errors.inspect
        format.html { render action: "new" }
      end
    end
  end

  # PUT /loans/1
  # PUT /loans/1.json
  def update
    @loan = Loan.find(params[:id])

    respond_to do |format|
      if @loan.update_attributes(params[:loan])
        if @loan.pending?
          flash[:error] = "Your reservation requires approval to be checked out for an extended period."
        end
        format.html { redirect_to @loan, notice: 'Loan was successfully updated.' }
      else
        logger.debug @loan.errors.inspect
        format.html { render action: "edit" }
      end
    end
  end

  # # DELETE /loans/1
  # # DELETE /loans/1.json
  # def destroy
  #   @loan = Loan.find(params[:id])

  #   @loan.cancel

  #   respond_to do |format|
  #     format.html { redirect_to loans_url }
  #     format.json { head :no_content }
  #   end
  # end

  private

  def set_default_checkout_length
    # stuff the default checkout length into the gon object if it's available
    gon.default_checkout_length = @default_checkout_length = Settings.default_check_out_duration
  end

  # setup javascript data structures to make the date picker work
  # def setup_datepicker_data_structures
  #   if !@reservation.new_record?
  #     gon.locations = @reservation.kit.location_and_availability_record_for_datepicker(90, @reservation)
  #   elsif @reservation.kit
  #     gon.locations = @reservation.kit.location_and_availability_record_for_datepicker
  #   elsif @reservation.component_model
  #     gon.locations = @reservation.component_model.locations_with_dates_circulating_for_datepicker
  #   end
  # end

end
