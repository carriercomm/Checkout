class SettingsController < ApplicationController

  # use CanCan to authorize this resource
  authorize_resource :settings

  # GET /settings/1
  # GET /settings/1.json
  def show
    @default_loan_duration = Settings.default_loan_duration
    @clients_can_see_equipment_outside_their_groups = Settings.clients_can_see_equipment_outside_their_groups
    @attendants_can_self_check_out = Settings.attendants_can_self_check_out
    respond_to do |format|
      format.html # show.html.erb
      # format.json { render json: @settings }
    end
  end

  # GET /settings/1/edit
  def edit
    @default_loan_duration = Settings.default_loan_duration
    @clients_can_see_equipment_outside_their_groups = Settings.clients_can_see_equipment_outside_their_groups
    @attendants_can_self_check_out = Settings.attendants_can_self_check_out
  end

  # PUT /settings/1
  # PUT /settings/1.json
  def update
    @default_loan_duration                          = params[:default_loan_duration].to_i || Settings.defaults[:default_loan_duration]
    @clients_can_see_equipment_outside_their_groups = (params[:clients_can_see_equipment_outside_their_groups] == 'true')
    @attendants_can_self_check_out                  = (params[:attendants_can_self_check_out] == 'true')

    saved = true

    # TODO: DRY this up

    unless @default_loan_duration.nil?
      obj = Settings.object('default_loan_duration') || Settings.new(var: 'default_loan_duration')
      obj.value = @default_loan_duration.to_i
      saved &&= obj.save
    end

    unless @clients_can_see_equipment_outside_their_groups.nil?
      obj = Settings.object('clients_can_see_equipment_outside_their_groups') || Settings.new(var: 'clients_can_see_equipment_outside_their_groups')
      obj.value = @clients_can_see_equipment_outside_their_groups
      saved &&= obj.save
    end

    unless @attendants_can_self_check_out.nil?
      obj = Settings.object('attendants_can_self_check_out') || Settings.new(var: 'attendants_can_self_check_out')
      obj.value = @attendants_can_self_check_out
      saved &&= obj.save
    end

    respond_to do |format|
      if saved
        format.html { redirect_to settings_path, notice: 'Settings were successfully updated.' }
        # format.json { head :no_content }
      else
        format.html { render action: "edit" }
        # format.json { render json: @settings.errors, status: :unprocessable_entity }
      end
    end
  end

end
