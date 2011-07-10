# -*- coding: utf-8 -*-
class ContestsController < ApplicationController
  menu :contest

  before_filter :require_user,
                :except => [:index, :last, :show]

  before_filter :require_judge, :only => [:create, :update, :destroy]
  before_filter :prepare_wmd, :only => [:edit, :new]

  def index
    @contests = Contest.paginate(:order => "start DESC", :page => params[:page], :per_page => 20)
    respond_to do |format|
      format.js { render :layout => false}
      format.html
    end
  end

  def last
    @contest = Contest.find(:last, :order => "start ASC")
    @numbers, @standings = @contest.standings
    render :action => 'show'
  end

  def show
    @contest = Contest.find(params[:id])
    @contributed = @contest.contributors.include? current_user
  end

  def new
    @contest = Contest.new
  end

  def create
    @contest = Contest.new(params[:contest])
    if @contest.save
      flash[:notice] = 'Тэмцээнийг үүсгэлээ.'
      redirect_to @contest
    else
      render :action => 'new'
    end
  end

  def edit
    @contest = Contest.find(params[:id])
  end

  def update
    @contest = Contest.find(params[:id])
    if @contest.update_attributes(params[:contest])
      flash[:notice] = 'Тэмцээнийг шинэчлэн хадгаллаа.'
      redirect_to @contest
    else
      render :action => 'edit'
    end
  end

  def destroy
    Contest.find(params[:id]).destroy
    redirect_to :action => 'index'
  end

end
