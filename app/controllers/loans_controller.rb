class LoansController < ApplicationController

  # use CanCan to authorize this resource
  authorize_resource

  layout 'sidebar', :only => ['index']

  # GET /loans
  # GET /loans.json
  def index
    if params[:user_id].present?
      @loans = User.find(params[:user_id]).loans.order("loans.starts_at DESC").page(params[:page])
    elsif params[:kit_id].present?
      @loans = Kit.find(params[:kit_id]).loans.order("loans.starts_at DESC").page(params[:page])
    else
      @loans = Loan.order("loans.starts_at DESC").page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /loans/1
  # GET /loans/1.json
  def show
    @loan = Loan.find(params[:id])
    @client      = @loan.client
    @kit         = @loan.kit
    @location    = @kit.location

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /loans/new
  # GET /loans/new.json
  def new
    @client = (params[:user_id]) ? User.find(params[:user_id]) : current_user

    # do we have a specific kit to check out?
    if params[:kit_id].present?
      @kit       = Kit.includes(:location).find(params[:kit_id])
      @loan      = @client.loans.build(:kit_id => @kit.id)
      @locations = [@kit.location]

      # setup javascript data structures to make the date picker work
      # TODO: move this to a model method on kit (same as implemented for ComponentModel)
      setup_kit_checkout_days(@kit)

    # do we have a general component_model to check out?
    elsif params[:component_model_id].present?
      @loan          = @client.loans.build
      @model         = ComponentModel.checkoutable.includes(:kits => :location).find(params[:component_model_id])
      @model         = ComponentModelDecorator.decorate(@model)
      @locations     = @model.checkout_locations
      @loan.location = @locations.first if @locations.size == 1
      gon.locations  = @model.checkout_dates_for_datepicker
    else
      flash[:error] = "Start by finding something to check out!"
      redirect_to component_models_path and return
    end

    # stuff the default checkout length into the gon object if it's available
    if @default_checkout_length = AppConfig.instance.default_checkout_length
      gon.default_checkout_length = @default_checkout_length
    end

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /loans/1/edit
  def edit
    @loan = Loan.find(params[:id])
    @kit         = @loan.kit
    setup_kit_checkout_days(@kit)
  end

  # POST /loans
  # POST /loans.json
  def create
    @loan = Loan.new(params[:loan])

    # validate that the item is checkoutable
    # validate that starts_at and ends_at are on checkout days
    # validate that the item isn't already reserved for the requested days
    # validate that this client has permissions

    respond_to do |format|
      if @loan.save
        format.html { redirect_to @loan, notice: 'Loan was successfully created.' }
      else
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
        format.html { redirect_to @loan, notice: 'Loan was successfully updated.' }
      else
        set_open_days
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /loans/1
  # DELETE /loans/1.json
  def destroy
    @loan = Loan.find(params[:id])
    @loan.destroy

    respond_to do |format|
      format.html { redirect_to loans_url }
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
