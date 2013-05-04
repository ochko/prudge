# -*- coding: utf-8 -*-
class SolutionsController < ApplicationController
  before_filter :require_user, :except=> [:submited, :solved, :best]

  def index
    @user = User.find(params[:user_id])
    @solutions = Solution.
      where(user_id: @user.id, contest_id: params[:contest_id]).
      order('created_at desc').preload(:problem)

    render :layout => false
  end

  def latest
    @solutions = Solution.
      order('solutions.source_updated_at desc').
      page(params[:page]).
      preload(:problem)
  end

  def show
    @solution = Solution.find(params[:id])
    render :action => :show
  end

  def submited
    @problem = Problem.find(params[:problem_id])
    @solutions = @problem.solutions.
      order('percent DESC, time ASC, source_updated_at ASC').
      preload(:user)
      
    if @solutions.empty?
      render :text => 'Энэ бодлогыг одоогоор нэг ч хүн бодоогүй байна'
    else
      render :partial => 'list'
    end
  end

  def view
    seeing { render :action => :view }
  end

  def download
    seeing do
      send_file(@solution.source.path,
                :filename => @solution.source_file_name,
                :disposition => 'attachment')
    end
  end

  def new
    @contest = Contest.find(params[:contest_id]) if params[:contest_id]
    @problem = (@contest ? @contest.problems : Problem).find(params[:problem_id])
    @solution = @problem.solutions.build(:contest => @contest)
    @solution.user = current_user

    creating
  end

  def create
    @contest = Contest.find(params[:contest_id]) if params[:contest_id]
    @problem = (@contest ? @contest.problems : Problem).find(params[:problem_id])
    @solution = @problem.solutions.build(params[:solution])
    @solution.user = current_user

    creating do
      if @solution.save
        @solution.post!
        flash[:notice] = 'Бодолтыг хадгалж авлаа.'
        redirect_to @solution
      else
        render :action => 'new'
      end
    end
  end

  def edit
    editing do
      @problem = @solution.problem
      @contest = @solution.contest
      render :action => 'edit'
    end
  end

  def update
    editing do
      if @solution.update_attributes(params[:solution])
        @solution.post!
        flash[:notice] = 'Бодолт шинэчлэгдлээ.'
        redirect_to @solution
      else
        render :action => 'edit'
      end
    end
  end

  def destroy
    editing do 
      @solution.destroy
      redirect_to @solution.problem
    end
  end

  def check
    @solution = Solution.find(params[:id])
    authorize! :check, @solution
    @solution.submit
    render :text => 'wait'
  rescue CanCan::AccessDenied => exception
    render :text => exception.message
  end

  private

  def seeing
    @solution = Solution.find(params[:id])
    authorize! :read, @solution
    current_user.saw!(@solution)
    yield
  rescue CanCan::AccessDenied => exception
    flash[:notice] = exception.message
    redirect_to @solution.competing? ? @solution.contest : @solution.problem
  end

  def editing
    @solution = Solution.find(params[:id])
    authorize! :modify, @solution
    Solution.transaction do
      yield
    end
  rescue CanCan::AccessDenied => exception
    flash[:notice] = exception.message
    redirect_to current_user.owns?(@solution) ? @solution : @solution.problem
  end

  def creating
    authorize! :create, @solution
    if block_given?
      Solution.transaction do
        yield
      end
    end
  rescue CanCan::AccessDenied => exception
    flash[:notice] = exception.message
    redirect_to (@solution.contest || @solution.previous || @solution.problem)
  end
end
