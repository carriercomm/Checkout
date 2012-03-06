class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :ensure_signed_in

  layout :layout_by_resource

  protected

  def ensure_signed_in
    unless devise_controller? || user_signed_in?
      redirect_to new_user_session_path
    end    
  end

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end

end
