class SplitComponentModelsController < ApplicationController

  before_filter :setup_instances

  def new
    # add a new model to the list to help streamline the user experience
    @split_component_model.component_models << ComponentModel.new
  end

  def create
    respond_to do |format|
      if @split_component_model.save
        format.html { redirect_to component_models_path, notice: 'Model was successfully split.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  private

  def setup_instances
    # make sure the current user has the proper privileges to do this
    authorize! :manage, ComponentModel

    # create the virtual model which is just an array of component model instances
    @split_component_model = SplitComponentModel.new(params[:split_component_model])

    # grab the model we're trying to split
    @component_model = ComponentModelDecorator.decorate(@split_component_model.root_component_model)
  end

end
