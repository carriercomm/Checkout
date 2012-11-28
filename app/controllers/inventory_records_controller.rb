class InventoryRecordsController < ApplicationController

  # use CanCan to authorize this resource
  authorize_resource

  # GET /inventory_records
  # GET /inventory_records.json
  def index
    if params[:kit_id]
      @inventory_records = InventoryRecord.joins(:component).where("components.kit_id = ?", params[:kit_id])
    else
      @inventory_records = InventoryRecord
    end

    @inventory_records = @inventory_records.order('inventory_records.created_at DESC').page(params[:page]).per(params[:page_limit])
    @inventory_records = InventoryRecordDecorator.decorate(@inventory_records)

    respond_to do |format|
      format.html # index.html.erb
      # format.json { render json: @inventory_records }
    end
  end

  # GET /inventory_records/1
  # GET /inventory_records/1.json
  # def show
  #   @inventory_record = InventoryRecordDecorator.find(params[:id])

  #   respond_to do |format|
  #     format.html # show.html.erb
  #     # format.json { render json: @inventory_record }
  #   end
  # end

  # GET /inventory_records/new
  # GET /inventory_records/new.json
  def new
    @kit = KitDecorator.find(params[:kit_id])
    @attendant = UserDecorator.decorate(current_user)
    @inventory_records = current_user.new_inventory_records(@kit)

    respond_to do |format|
      format.html # new.html.erb
      # format.json { render json: @inventory_record }
    end
  end

  # GET /inventory_records/1/edit
  # def edit
  #   @inventory_record = InventoryRecord.find(params[:id])
  # end

  # POST /inventory_records
  # POST /inventory_records.json
  def create
    @kit = KitDecorator.find(params[:kit_id])
    @attendant = UserDecorator.decorate(current_user)
    @inventory_records = []
    success = true

    params[:user][:inventory_records_attributes].each do |k,attrs|
      ir = InventoryRecord.new
      ir.attendant           = current_user
      ir.inventory_status_id = attrs[:inventory_status_id].to_i
      ir.component_id        = attrs[:component_id].to_i
      @inventory_records << ir
      success &&= ir.save
    end

    respond_to do |format|
      if success
        format.html { redirect_to @kit, notice: 'Inventory records were successfully created.' }
        # format.json { render json: @inventory_record, status: :created, location: @inventory_record }
      else
        format.html { render action: "new" }
        # format.json { render json: @inventory_record.errors, status: :unprocessable_entity }
      end
    end
  end

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
