class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :ensure_signed_in

  # NOTE: layout for Devise is setup in config/application.rb

  protected

  def ensure_signed_in
    unless user_signed_in? || devise_controller?
      redirect_to new_user_session_path
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

end
