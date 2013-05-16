# -*- coding: utf-8 -*-
class PasswordResetsController < ApplicationController
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  before_filter :require_no_user

  def new
  end

  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.send_password_reset_instructions!
      flash_notice :password_reset_instructions
      redirect_to root_url
    else
      flash_notice :user_not_found_by_email
      render :action => :new
    end  
  end

  def edit
  end

  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash_notice :password_updated
      redirect_to account_users_url
    else
      render :action => :edit
    end
  end

  private

  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash_notice :password_reset_not_found
      redirect_to root_url
    end
  end

end  
