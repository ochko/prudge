# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:account, :show, :edit, :update]

  def new
    @user = User.new
    render :layout => 'bare'
  end

  def create
    @user = User.new(params[:user])
    @user.save do |result|
      if result
        flash[:notice] = "Бүртгэл амжилттай"
        redirect_back_or_default account_url
      else
        render :action => :new
      end
    end
  end

  def edit
    @user = @current_user
  end

  def update
    @user = current_user
    @user.attributes = params[:user]
    @user.save do |result|
      if result
        flash[:notice] = "Мэдээллийг шинэчиллээ!"
        redirect_to account_url
      else
        render :action => 'edit'
      end
    end
  end

  def index
    @users = User.order("points DESC").page(params[:page]).per(100)
  end

  def account
    if current_user
      redirect_to :action=> 'show', :id => current_user
    else
      store_location
      redirect_to :action=> :login
    end
  end

  def show
    @user = User.find(params[:id])
    @standings = []
    @user.contests.each do |contest|
      numbers, standings = contest.standings
      idx = standings.index(@user)
      next unless idx
      @standings << [contest, numbers[idx]]
    end
  end

  def solutions
    @solutions = User.find(params[:id]).solutions.
      order('source_updated_at DESC').
      page(params[:page]).
      preload(:problem)

    if @solutions.empty?
      render :text => '', :status => 404
    else
      render :partial => 'users/solution', :collection => @solutions
    end
  end

  def problems
    @user = User.find(params[:id])
    render :partial => 'problems'
  end
end
