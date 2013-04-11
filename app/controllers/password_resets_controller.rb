# -*- coding: utf-8 -*-
class PasswordResetsController < ApplicationController
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  before_filter :require_no_user
  
  def new  
    render  
  end  
  
  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.send_password_reset_instructions!
      flash[:notice] = "Нууц үг сэргээх зааврыг и-мэйл рүү тань илгээв." +
        "Шалгана уу?"
      redirect_to root_url
    else
      flash[:notice] = "Ийм и-мэйлээр бүртгүүлсэн хэрэглэгч алга байна!"
      render :action => :new
    end  
  end
  
  def edit
    render
  end
 
  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = "Нууц үгийг амжилттай шинэчиллээ"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
  
  private  
  
  def load_user_using_perishable_token  
    @user = User.find_using_perishable_token(params[:id])  
    unless @user  
      flash[:notice] = "Уучлаарай, таны бүртгэлийг олсонгүй. " +  
        "И-мэйл дотроосоо URL ийг хуулж аваад хөтөч дээрээ ачаалж үз, эсвэл " +
        "нууц үг сэргээх процессийг ахин хийж үзнэ үү?"
      redirect_to root_url  
    end  
  end
  
end  
