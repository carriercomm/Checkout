class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :ensure_signed_in
  layout        :layout_by_action

  # NOTE: layout for Devise is setup in config/application.rb

  protected

  def layout_by_action
    case action_name
    when 'index'
      'sidebar'
    else
      'no_sidebar'
    end
  end

  # def layout_by_role
  #   if current_user.has_role? :admin
  #     "admin"
  #   else
  #     "application"
  #   end
  # end

  def ensure_signed_in
    unless user_signed_in? || devise_controller?
      redirect_to new_user_session_path
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

end
