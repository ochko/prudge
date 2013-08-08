# -*- coding: utf-8 -*-

class ContestsController < ApplicationController

  authorize_resource :contest, :except => [:index, :last, :show]
  respond_to :html

  def index
    @contests = Contest.order("start DESC").page(params[:page]).per(20)
  end

  def watch
    contest.watchers << current_user
    render nothing: true
  end

  def unwatch
    contest.watchers.delete current_user
    render nothing: true
  end

  def last
    @contest = Contest.find(:last, :order => "start ASC")
    init_user_data
    render :show
  end

  def contestants
    if contest.participants.size > 0
      render :partial => 'contestants'
    else
      render :text => message_for(:no_contestants)
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
      flash_notice
      redirect_to @contest
    else
      render :new
    end
  end

  def edit
    respond_with contest
  end

  def update
    if contest.update_attributes(params[:contest])
      flash_notice
      redirect_to contest
    else
      render :edit
    end
  end

  def destroy
    contest.destroy
    flash_notice
    redirect_to contests_url
  end

  protected

    def init_user_data
      @solved = { }
      if current_user
        current_user.solutions.
          where(contest_id: @contest.id).
          each{ |s| @solved[s.problem_id] = s.state }
      end
    end

  private
    def contest
      @contest ||= Contest.find(params[:id])
    end
end
