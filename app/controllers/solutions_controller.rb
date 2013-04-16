# -*- coding: utf-8 -*-
class SolutionsController < ApplicationController
  menu :problem

  before_filter :require_user, :except=> [:submited, :solved, :best]

  def index
    @solutions = Solution.
      paginate(:page => params[:page],
               :order => 'solutions.source_updated_at desc').
      preload(:problem)

    respond_to do |format|
      format.js { render :layout => false }
      format.html
    end
  end

  def show
    seeing { render :action => :show }
  end

  def best
    @problem = Problem.find(params[:problem_id])
    @solution = @problem.solutions.best
    unless @solution
      render :text => '<table><tr><td>Энэ бодлогыг одоогоор нэг ч хүн бодоогүй байна</td></tr</table>'
    else
      render :partial => 'best'
    end
  end

  def submited
    @problem = Problem.find(params[:problem_id])
    @solutions = @problem.solutions(:order => 'source_updated_at DESC').preload(:user)
      
    if @solutions.empty?
      render :text => '<table><tr><td>Энэ бодлогыг одоогоор нэг ч хүн бодоогүй байна</td></tr</table>'
    else
      render :partial => 'list'
    end
  end

  def solved
    @problem = Problem.find(params[:problem_id])
    @solutions = @problem.solutions.correct(:order => 'source_updated_at DESC').preload(:user)
    if @solutions.empty?
      render :text => '<table><tr><td>Энэ бодлогыг одоогоор нэг ч хүн зөв бодоогүй байна</td></tr</table>'
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
    @solution = Solution.new(:problem_id => params[:problem])
    @solution.apply_contest
    creating
  end

  def create
    @solution = current_user.solutions.build(params[:solution])
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
    editing { render :action => 'edit' }
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
