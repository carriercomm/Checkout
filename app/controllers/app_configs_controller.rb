class AppConfigsController < ApplicationController

  # use CanCan to authorize this resource
  authorize_resource

  before_filter :load_config

  # GET /app_config/1
  # GET /app_config/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      # format.json { render json: @app_config }
    end
  end

  # GET /app_config/1/edit
  def edit

  end

  # PUT /app_config/1
  # PUT /app_config/1.json
  def update
    respond_to do |format|
      if @app_config.update_attributes(params[:app_config])
        format.html { redirect_to app_config_path, notice: 'App config was successfully updated.' }
        # format.json { head :no_content }
      else
        format.html { render action: "edit" }
        # format.json { render json: @app_config.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def load_config
    @app_config = AppConfigDecorator.decorate(AppConfig.instance)
  end

end
