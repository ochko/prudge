# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery

  helper_method :current_user_session, :current_user, :current_user?, :admin?, :judge?

  def current_ability
    @current_ability ||=
      if current_user.nil?
        BaseAbility
      elsif current_user.admin?
        AdminAbility
      elsif current_user.judge?
        JudgeAbility
      else
        CoderAbility
      end.
      new(current_user)
  end

  private

  def message_for(name, options = {})
    I18n.translate name, options.merge(:scope => :message)
  end

  def flash_notice(name, options = {})
    flash[:notice] = message_for(name, options)
  end

  def admin?
    current_user && current_user.admin
  end

  def judge?
    current_user && current_user.judge
  end

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
      respond_to do |format|
        format.html do
          store_location
          flash[:notice] = "Энэ хуудас руу орохын тулд нэвтэрсэн байх хэрэгтэй"
          redirect_to login_url
        end
        format.js { render :text => "Ийшээ хандахын тулд ЛОГИН хийнэ үү?"}
      end
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "Энэ хуудас руу орохын тулд гарсан байх ёстой"
      redirect_to root_url
      return false
    end
  end
  
  def store_location
    if request.format == "html"
      session[:return_to] = request.url
    end
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end
