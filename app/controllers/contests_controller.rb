# -*- coding: utf-8 -*-
class ContestsController < ApplicationController
  before_filter :require_user, :except => [:index, :last, :show]
  before_filter :require_judge, :only => [:create, :update, :destroy]

  def index
    @contests = Contest.order("start DESC").page(params[:page]).per(20)

    respond_to do |format|
      format.js { render :layout => false}
      format.html
    end
  end

  def watch
    contest = Contest.find params[:id]
    contest.watchers << current_user
    render :nothing => true
  end

  def unwatch
    contest = Contest.find params[:id]
    contest.watchers.delete current_user
    render :nothing => true
  end

  def last
    @contest = Contest.find(:last, :order => "start ASC")
    init_user_data
    render :action => 'show'
  end

  def contestants
    @contest = Contest.find(params[:id])
    @numbers, @standings = @contest.standings

    if @contest.users.size > 0
      render :partial => 'contestants'
    else
      render :text => 'Оролцогч алга!'
    end
  end

  def show
    @contest = Contest.find(params[:id])
    init_user_data
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

  protected

  def init_user_data
    @contributed = @contest.contributors.include? current_user
    @solved = { }
    if current_user
      current_user.solutions.
        where(contest_id: @contest.id).
        each{ |s| @solved[s.problem_id] = s.state }
    end
  end
end
