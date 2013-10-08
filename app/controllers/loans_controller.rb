class LoansController < ApplicationController

  # TODO: localize all these messages

  # use CanCan to authorize this resource
  authorize_resource

  decorates_assigned :loan
  decorates_assigned :loans

  before_filter :set_default_loan_duration

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

    @filter = params[:filter] || "all"

    case @filter
    when "pending"     then @loans = @loans.where("loans.workflow_state = 'pending'")
    when "approved"    then @loans = @loans.where("loans.workflow_state = 'approved'")
    when "checked_out" then @loans = @loans.where("loans.workflow_state = 'checked_out'")
    when "checked_in"  then @loans = @loans.where("loans.workflow_state = 'checked_in'")
    when "rejected"    then @loans = @loans.where("loans.workflow_state = 'rejected'")
    when "canceled"    then @loans = @loans.where("loans.workflow_state = 'canceled'")
      #      when "archived"    then @loans = @loans.where("loans.in_at IS NOT NULL OR ")
    end

    @loans = @loans.order("loans.starts_at DESC").page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  # get /loans/1
  # get /loans/1.json
  def show
    @loan = Loan.find(params[:id])

    respond_to do |format|
      format.html { render layout: 'sidebar' } # show.html.erb
    end
  end


  # get /loans/new
  # get /loans/new.json
  def new
    unless params[:kit_id].present?
      redirect_to categories_path, alert: "Must have a specific to kit to create a loan"
    end

    case params[:a]
    when "check_out"
      # 1) we have a kit number and want to check it out
      prepare_check_out and return
    when "request"
      # 2) we have a kit number and want to request it
      prepare_request and return
    else
      raise "this feature is not implemented: #{ params[:a].to_s }"
    end

    # do we have a general component_model to check out?
    # elsif params[:component_model_id].present?
    #   @component_model = componentmodel.find(params[:component_model_id]).decorate
    #   @kits            = component_model.kits

    #   # setup javascript data structures to make the date picker work
    #   gon.locations = @component_model.locations_with_dates_circulating_for_datepicker
    #   format.html { render :kit_select } and return

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # get /loans/1/edit
  def edit
    a     = params.delete(:a)
    @loan = Loan.find(params[:id])

    case a
    when "check_in"
      redirect_to @loan, notice: "Loan already checked in" if @loan.checked_in?
      prepare_check_in and return
    when "check_out"
      redirect_to @loan, notice: "Loan already checked out" if @loan.checked_out?
      prepare_check_out and return
    else
      if @loan.requested?
        prepare_request and return
      end
      raise "Action '#{a}' is not implemented!"
    end

  end

  # post /loans
  # post /loans.json
  def create
    a     = params.delete(:a)
    @loan = Loan.new(params[:loan])

    case a
    when "check_out"
      do_check_out and return
    when "request"
      do_request and return
    else
      raise "Action '#{a}' is not implemented!"
    end

    # respond_to do |format|
    #   # if @loan.kit.nil? && @loan.component_model && @loan.location && @loan.starts_at && @loan.ends_at
    #   #   @kits = kitdecorator.decorate(@loan.available_circulating_kits)
    #   #   format.html { render :kit_select }
    #   if @loan.save
    #     if @loan.pending?
    #       flash[:error] = "your reservation requires approval to be checked out for an extended period."
    #     end
    #     format.html { redirect_to @loan, notice: 'Loan was successfully created.' }
    #   else
    #     logger.debug @loan.errors.inspect
    #     format.html { render action: "new" }
    #   end
    # end
  end

  # put /loans/1
  # put /loans/1.json
  def update
    a     = params.delete(:a)
    @loan = Loan.find(params[:id])

    case a
    when "check_in"
      do_check_in and return
    when "check_out"
      do_check_out and return
    when "cancel"
      raise "cancel not implemented!"
    when "decline"
      raise "declined not implemented!"
    when "mark_lost"
      raise "mark_lost not implemented!"
    when "renew"
      do_renew and return
    when "request"
      do_request and return
    when "resubmit"
      raise "resubmit not implemented!"
    else
      raise "Action '#{a}' is not implemented!"
    end

    # respond_to do |format|
    #   if @loan.update_attributes(params[:loan])
    #     if @loan.pending?
    #       flash[:error] = "your reservation requires approval to be checked out for an extended period."
    #     end
    #     format.html { redirect_to @loan, notice: 'loan was successfully updated.' }
    #   else
    #     logger.debug @loan.errors.inspect
    #     format.html { render action: "edit" }
    #   end
    # end
  end

  # # delete /loans/1
  # # delete /loans/1.json
  # def destroy
  #   @loan = loan.find(params[:id])

  #   @loan.cancel

  #   respond_to do |format|
  #     format.html { redirect_to loans_url }
  #     format.json { head :no_content }
  #   end
  # end

  private

  def do_check_in
    @loan.new_check_in_inventory_record(attendant: current_user, kit: @loan.kit)

    # TODO: revisit this with strong_parameters
    if idas = get_check_in_inventory_details_attributes
      inv_det_params = {}
      idas.each {|k, v| inv_det_params[v["component_id"].to_i] = v["missing"] }
      @loan.check_in_inventory_record.inventory_details.each do |inv_det|
        inv_det.missing = inv_det_params[inv_det.component_id]
      end
    end

    @loan.in_at = DateTime.current

    if @loan.ends_at > @loan.in_at
      # truncate ends_at since this loan was returned early, that
      # way the kit will be available in the system for another check out
      @loan.ends_at = @loan.in_at
    end

    @loan.check_in!

    respond_to do |format|
      if !@loan.halted? && @loan.save
        format.html { redirect_to @loan, notice: 'Loan was successfully checked in.' }
      else
        logger.debug "Halted because: #{@loan.halted_because.to_s}"
        logger.debug @loan.errors.inspect
        flash[:alert] = "There are some problems with your check in. Check below for errors."
        format.html { render "check_in" }
      end
    end
  end

  def do_check_out
    now = DateTime.current

    if @loan.requested?
      @loan.new_check_out_inventory_record(attendant: current_user, kit: @loan.kit)

      # TODO: revisit this with strong_parameters
      if idas = get_check_out_inventory_details_attributes
        inv_det_params = {}
        idas.each {|k, v| inv_det_params[v["component_id"].to_i] = v["missing"] }
        @loan.check_out_inventory_record.inventory_details.each do |inv_det|
          inv_det.missing = inv_det_params[inv_det.component_id]
        end
      end
    else
      @loan.check_out_inventory_record.kit       = @loan.kit
      @loan.check_out_inventory_record.attendant = current_user
      @loan.starts_at = now
      @loan.autofill_ends_at!
      @loan.approve!
    end

    @loan.out_at = DateTime.current
    @loan.check_out! unless @loan.halted?

    respond_to do |format|
      if !@loan.halted? && @loan.save
        format.html { redirect_to @loan, notice: 'Loan was successfully created.' }
      else
        logger.debug "Halted because: #{@loan.halted_because.to_s}"
        logger.debug @loan.errors.inspect
        flash[:alert] = "There are some problems with your check out. Check below for errors."
        format.html { render "check_out" }
      end
    end
  end

  def do_renew
    @loan.renew!
    respond_to do |format|
      if !@loan.halted? && @loan.save
        format.html { redirect_to @loan, notice: 'Loan was successfully renewed.' }
      else
        logger.debug "Loan could not be renewed because #{ @loan.halted_because.to_s }."
        format.html { redirect_to @loan, alert: "Loan could not be renewed because:<br> #{ @loan.halted_because.to_s }.".html_safe }
      end
    end
  end

  def do_request
    if @loan.requested?
      @loan.unapprove!
      @loan.starts_at = params[:loan][:starts_at]
    end

    @loan.autofill_ends_at!
    @loan.approve!

    respond_to do |format|
      if !@loan.halted? && @loan.save
        format.html { redirect_to @loan, notice: 'Loan was successfully requested.' }
      else
        logger.debug "Loan could not be requested because #{ @loan.halted_because.to_s }."
        logger.debug @loan.errors.inspect
        format.html { redirect_to @loan, alert: "Loan could not be requested because:<br> #{ @loan.halted_because.to_s }.".html_safe }
      end
    end
  end

  def get_check_in_inventory_details_attributes
    if params[:loan] && params[:loan][:check_in_inventory_record_attributes]
      return params[:loan][:check_in_inventory_record_attributes][:inventory_details_attributes]
    else
      return nil
    end
  end

  def get_check_out_inventory_details_attributes
    if params[:loan] && params[:loan][:check_out_inventory_record_attributes]
      return params[:loan][:check_out_inventory_record_attributes][:inventory_details_attributes]
    else
      return nil
    end
  end

  def prepare_check_in
    # stub out the inventory records
    @loan.new_check_in_inventory_record(attendant: current_user)
    @loan.in_at = DateTime.current
    if @loan.ends_at < @loan.in_at
      @loan.late = true
    end

    respond_to do |format|
      format.html { render 'check_in' }
    end

  end

  def prepare_check_out
    now = DateTime.current

    if @loan
      if @loan.starts_at.at_beginning_of_day > now.at_beginning_of_day
        redirect_to @loan, alert: "This loan is scheduled to be picked up on #{ loan.starts_at }" and return
      end
      @loan.out_at = now
    else
      kit = Kit.find(params[:kit_id])

      unless kit
        redirect_to(kits_path, alert: "Could not find kit: #{ params[:kit_id].to_s }") and return
      end

      @loan = Loan.new(kit: kit, starts_at: now, out_at: now, client: nil)
      @loan.autofill_ends_at!
    end

    # stub out the inventory records
    @loan.new_check_out_inventory_record(attendant: current_user)

    respond_to do |format|
      format.html { render 'check_out' }
    end

  end

  def prepare_request
    unless @loan
      kit       = Kit.find params[:kit_id]
      client    = (params[:user_id]) ? user.find(params[:user_id]) : current_user
      starts_at = kit.location.next_datetime_open
      @loan     = Loan.new(kit: kit, starts_at: starts_at, client: client)
    end

    # setup javascript data structures to make the date picker work
    gon.pickup_dates = @loan.kit.pickup_times_for_datepicker

    respond_to do |format|
      format.html { render 'request' }
    end
  end

  def set_default_loan_duration
    # stuff the default checkout length into the gon object if it's available
    gon.default_loan_duration = @default_loan_duration = Settings.default_loan_duration
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
