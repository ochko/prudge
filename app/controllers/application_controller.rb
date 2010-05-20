# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery
  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user, :current_user?, :admin?, :judge?

  protected
  def prepare_wmd
    @wmd_needed = true
  end

  private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def current_user?(user)
    return false unless current_user
    current_user.id == user.id
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = "Энэ хуудас руу орохын тулд нэвтэрсэн байх хэрэгтэй"
      redirect_to login_url
      return false
    end
  end

  def require_judge
    unless current_user && current_user.judge?
      store_location
      flash[:notice] = "Шүүгч л хандах эрхтэй!"
      redirect_to root_url
      return false
    end
  end

  def require_admin
    unless current_user && current_user.admin?
      store_location
      flash[:notice] = "Админ л хандах эрхтэй!"
      redirect_to root_url
      return false
    end
  end

  def admin?
    current_user && current_user.admin
  end

  def judge?
    current_user && current_user.judge
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "Энэ хуудас руу орохын тулд гарсан байх ёстой"
      redirect_to me_url
      return false
    end
  end
  
  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end


end
