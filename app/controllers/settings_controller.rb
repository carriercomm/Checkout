class SettingsController < ApplicationController

  # use CanCan to authorize this resource
  authorize_resource :settings

  # GET /app_config/1
  # GET /app_config/1.json
  def show
    @default_check_out_duration = Settings.default_check_out_duration
    @clients_can_see_equipment_outside_their_groups = Settings.clients_can_see_equipment_outside_their_groups
    @attendants_can_self_check_out = Settings.attendants_can_self_check_out
    respond_to do |format|
      format.html # show.html.erb
      # format.json { render json: @app_config }
    end
  end

  # GET /app_config/1/edit
  def edit
    @default_check_out_duration = Settings.default_check_out_duration
    @clients_can_see_equipment_outside_their_groups = Settings.clients_can_see_equipment_outside_their_groups
    @attendants_can_self_check_out = Settings.attendants_can_self_check_out
  end

  # PUT /app_config/1
  # PUT /app_config/1.json
  def update
    @default_check_out_duration                     = params[:default_check_out_duration].to_i || Settings.defaults[:default_check_out_duration]
    @clients_can_see_equipment_outside_their_groups = (params[:clients_can_see_equipment_outside_their_groups] == 'true')
    @attendants_can_self_check_out                  = (params[:attendants_can_self_check_out] == 'true')

    saved = true

    obj = Settings.object('default_check_out_duration')
    obj.value = @default_check_out_duration
    saved &&= obj.save

    obj = Settings.object('clients_can_see_equipment_outside_their_groups')
    obj.value = @clients_can_see_equipment_outside_their_groups
    saved &&= obj.save

    obj = Settings.object('attendants_can_self_check_out')
    obj.value = @attendants_can_self_check_out
    saved &&= obj.save

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
