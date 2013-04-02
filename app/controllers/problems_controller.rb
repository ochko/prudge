# -*- coding: utf-8 -*-
class ProblemsController < ApplicationController
  menu :problem

  before_filter :require_user,
                :except => [:index, :show]

  before_filter :require_judge, :only => [:destroy, :proposals, :check]
  before_filter :prepare_wmd, :only => [:edit, :new]

  def index
    respond_to do |format|
      format.html do
        order = params[:order] || 'DESC'
        column = params[:column] || 'created_at'
        @reverse = (order == 'ASC') ? 'DESC' : 'ASC'

        @problems = Problem.active.
          paginate(:page => params[:page], :per_page => 20, :include => :user, 
                   :order => "#{column} #{order}")
      end
      format.rss do
        @problems = Problem.active(:order => 'created_at DESC',
                                   :include => :user, :limit => 10)
        render :layout => false
      end
    end

  end

  def proposals
    @problems = Problem.find(:all, :conditions => ["contest_id IS NULL"])
  end

  def show
    @problem = Problem.find(params[:id])
    unless @problem.available_to(current_user)
      flash[:notice] = 'Та нэвтрээгүй, эсвэл тухай бодлогыг одоогоор үзэх боломжгүй байна'
      redirect_to :action => :index
    end
  end

  def new
    @problem = Problem.new
  end

  def create
    params[:problem].delete('contest_id') unless judge?
    @problem = current_user.problems.build(params[:problem])
    if @problem.save
      flash[:notice] = 'Бодлогыг хадгалав. Тэстүүдийг нь оруулна уу?'
      redirect_to @problem
    else
      render :action => 'new'
    end
  end

  def edit
    @problem = Problem.find(params[:id])
    unless @problem.has_permission?(current_user)
      flash[:notice] = 'Энэ бодлогыг одоо засаж болохгүй!'
      redirect_to :action => 'list'
    end
  end

  def update
    @problem = Problem.find(params[:id])
    if @problem.has_permission?(current_user)
      params[:problem].delete('contest_id') unless judge?
      if @problem.update_attributes(params[:problem])
        flash[:notice] = 'Бодлогыг шинэчиллээ.'
        redirect_to @problem
      else
        render :action => 'edit'
      end
    else
      flash[:notice] = 'Энэ бодлогыг одоо засаж болохгүй!'
      redirect_to :action => :index
    end
  end

  def destroy
    @problem = Problem.find(params[:id])
    if @problem.solutions.size == 0
      @problem.destroy
      redirect_to :action => :index
    else
      flash[:notice] = 'Энэ бодлогод бодолтууд байгаа учраас устгахгүй.'
      redirect_to @problem
    end
  end

  def check
    @problem = Problem.find(params[:id])
    @problem.check!
    flash[:notice] = "Бүх бодолтуудыг шалгалаа"
    redirect_to @problem
  end

end
