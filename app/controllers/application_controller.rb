class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale
  helper_method :current_user

  def set_locale
    if !params[:locale].nil?
      I18n.locale = params[:locale]
    end
  end

  private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end
end
