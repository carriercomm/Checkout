class InventoryRecordsController < ApplicationController

  # use CanCan to authorize this resource
  authorize_resource

  decorates_assigned :kit
  decorates_assigned :attendant
  decorates_assigned :inventory_record
  decorates_assigned :inventory_records

  # GET /inventory_records
  # GET /inventory_records.json
  def index
    # TODO: implement filters

    if params[:kit_id]
      @inventory_records = Kit.find(params[:kit_id].to_i).inventory_records
    else
      @inventory_records = InventoryRecord
    end

    @inventory_records = @inventory_records.order('inventory_records.created_at DESC')
      .page(params[:page])
      .per(params[:page_limit])

    respond_to do |format|
      format.html # index.html.erb
      # format.json { render json: @inventory_records }
    end
  end

  # GET /inventory_records/1
  # GET /inventory_records/1.json
  def show
    @inventory_record = InventoryRecord
      .joins(:inventory_details)
      .includes(:inventory_details)
      .find(params[:id])

    respond_to do |format|
      format.html  { render layout: 'sidebar' } # show.html.erb
      # format.json { render json: @inventory_record }
    end
  end

  # TODO: implement audit inventory record creation

  # GET /inventory_records/new
  # GET /inventory_records/new.json
  # def new
  #   @kit = Kit.find(params[:kit_id])
  #   @attendant = current_user
  #   @inventory_record = @kit.build_inventory_record(kit: @kit, attendant: @attendant)
  #   @inventory_record.initialize_inventory_details

  #   respond_to do |format|
  #     format.html # new.html.erb
  #     # format.json { render json: @inventory_record }
  #   end
  # end

  # GET /inventory_records/1/edit
  # def edit
  #   @inventory_record = InventoryRecord.find(params[:id])
  # end

  # POST /inventory_records
  # POST /inventory_records.json
  # def create
  #   @kit = Kit.find(params[:kit_id])
  #   @attendant = current_user
  #   raise params.inspect
  #   @inventory_records = []
  #   success = true

  #   params[:user][:inventory_records_attributes].each do |k,attrs|
  #     ir = InventoryRecord.new
  #     ir.attendant           = current_user
  #     ir.inventory_status_id = attrs[:inventory_status_id].to_i
  #     ir.component_id        = attrs[:component_id].to_i
  #     @inventory_records << ir
  #     success &&= ir.save
  #   end

  #   respond_to do |format|
  #     if success
  #       format.html { redirect_to @kit, notice: 'Inventory records were successfully created.' }
  #       # format.json { render json: @inventory_record, status: :created, location: @inventory_record }
  #     else
  #       format.html { render action: "new" }
  #       # format.json { render json: @inventory_record.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PUT /inventory_records/1
  # PUT /inventory_records/1.json
  # def update
  #   @inventory_record = InventoryRecord.find(params[:id])

  #   respond_to do |format|
  #     if @inventory_record.update_attributes(params[:inventory_record])
  #       format.html { redirect_to @inventory_record, notice: 'Inventory record was successfully updated.' }
  #       # format.json { head :no_content }
  #     else
  #       format.html { render action: "edit" }
  #       # format.json { render json: @inventory_record.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /inventory_records/1
  # DELETE /inventory_records/1.json
  # def destroy
  #   @inventory_record = InventoryRecord.find(params[:id])
  #   @inventory_record.destroy

  #   respond_to do |format|
  #     format.html { redirect_to inventory_records_url }
  #     # format.json { head :no_content }
  #   end
  # end
end
