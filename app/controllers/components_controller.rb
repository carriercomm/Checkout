class ComponentsController < ApplicationController

  # use CanCan to authorize this resource
  authorize_resource
  before_filter :strip_brand, :only => [:create, :update, :destroy]

  decorates_assigned :budgets
  decorates_assigned :component
  decorates_assigned :components
  decorates_assigned :inventory_details

  # GET /components
  # GET /components.json
  def index
    @components = Component

    apply_scopes_and_pagination

    respond_to do |format|
      format.html # index.html.erb
#      format.json { render json: @components }
    end
  end

  # GET /components/1
  # GET /components/1.json
  def show
    @component = Component.find(params[:id])
    @inventory_details = @component
      .inventory_details
      .includes(:inventory_record)
      .joins(:inventory_record)
      .order("inventory_details.created_at DESC")
      .limit(10)

    respond_to do |format|
      format.html # show.html.erb
      format.js
      #format.json { render json: @component }
    end
  end

=begin

  # GET /admin/components/new
  # GET /admin/components/new.json
  def new
    @component = Component.new
    @component.model = Model.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @component }
    end
  end
=end

  # GET /admin/components/1/edit
  def edit
    @component = Component.find(params[:id])
    @budgets   = Budget.active
  end

=begin
  # POST /admin/components
  # POST /admin/components.json
  def create
    @component = Component.new(params[:component])

    respond_to do |format|
      if @component.save
        format.html { redirect_to component_path(@component), notice: 'Component was successfully created.' }
        format.json { render json: @component, status: :created, location: @component }
      else
        format.html { render action: "new" }
        format.json { render json: @component.errors, status: :unprocessable_entity }
      end
    end
  end

=end


  # PUT /admin/components/1
  # PUT /admin/components/1.json
  def update
    @component = Component.find(params[:id])

    respond_to do |format|
      if @component.update_attributes(params[:component])
        format.html { redirect_to admin_component_path(@component), notice: 'Component was successfully updated.' }
        format.js
      else
        format.html { render action: "edit" }
        format.js   { render :template => 'components/error.js.erb' }
      end
    end
  end

=begin

  # DELETE /admin/components/1
  # DELETE /admin/components/1.json
  def destroy
    @component = Component.find(params[:id])
    @component.destroy

    respond_to do |format|
      format.html { redirect_to components_url }
      format.json { head :no_content }
    end
  end
=end

  private

  def apply_scopes_and_pagination
    scope_by_filter_params
    scope_by_brand
    scope_by_budget
    scope_by_category
    scope_by_component_model

    @components = @components.includes(:kit, :component_model => :brand)
      .joins(:kit, :component_model => :brand)
      .order("components.kit_id DESC")
      .page(params[:page])
  end

  def scope_by_filter_params
    @filter = params[:filter] || "all"

    case params[:filter]
    when "circulating"     then @components = @components.includes(:kits).where("kits.workflow_state = 'circulating'")
    when "deaccessioned"   then @components = @components.includes(:kits).where("kits.workflow_state = 'deaccessioned'")
    when "missing"         then @components = @components.missing
    when "non_circulating" then @components = @components.includes(:kits).where("kits.workflow_state = 'non_circulating'")
    when "orphaned"        then @components = @components.where("components.kit_id IS NULL")
    end
  end

  # TODO: does this make any sense? this might need to be fixed to
  #       work with multiple brands in a kit
  def scope_by_brand
    @components = @components.brand(params["brand_id"]) if params["brand_id"].present?
  end

  def scope_by_component_model
    @components = @components.where("component_model_id = ?", params["component_model_id"].to_i) if params["component_model_id"].present?
  end

  def scope_by_budget
    @components = @components.where(budget_id: params["budget_id"]) if params["budget_id"].present?
  end

  def scope_by_category
    @components = @components.category(params["category_id"]) if params["category_id"].present?
  end

  def strip_brand
    # throw away the brand, since its information is carried by the model
    model_attrs = !!params[:component] ? params[:component].delete(:model_attributes) : nil
  end

end
