# -*- coding: utf-8 -*-
class SplitComponentModelsController < ApplicationController

  before_filter :setup_instances

  def new
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
    # root_component_model_id = params[:split_component_model][:root_component_model_id].try(:to_i)
    # @component_model       = ComponentModel.includes(:brand).find(root_component_model_id)
    # @split_component_model = SplitComponentModel.new(root_component_model: @component_model)
    @split_component_model = SplitComponentModel.new(params[:split_component_model])
    @component_model       = ComponentModelDecorator.decorate(@split_component_model.root_component_model)
  end

end
