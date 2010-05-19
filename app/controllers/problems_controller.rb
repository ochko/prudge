# -*- coding: utf-8 -*-
class ProblemsController < ApplicationController
  before_filter :require_user,
                :except => [:index, :list, :show, :text, :feed]

  before_filter :require_judge, :only => [:destroy, :nominated]

  def index
    if params[:order]
      order_direction = session[:order] || 'ASC'
      order_direction = (order_direction == 'ASC') ? 'DESC' : 'ASC'
      order_sql = params[:order] + ' ' + order_direction
      session[:order] = order_direction
    end

    @my_solutions = []
    @my_solutions = current_user.solutions if current_user
 
    @problems = Problem.
        paginate(:page => params[:page], :per_page => 30,
             :select => "problems.*, u.login as login, count(s.id) as solutions_count, "+
             "sum(s.correct) as corrects_count",
             :joins => "join contests c on c.id = problems.contest_id " +
             "left join users u on problems.user_id = u.id " +
             "left join solutions s on problems.id = s.problem_id ",
             :order => order_sql,
             :conditions => ["c.start < NOW()"],
             :group => "problems.id")
    end
  end

  def feed
    @problems = Problem.
      find_by_sql("SELECT p.*, u.login "+
                  "FROM problems p "+
                  "join contests c on p.contest_id = c.id "+
                  "join users u on p.user_id = u.id "+
                  "where c.start < NOW() "+
                  "order by p.created_at desc "+
                  "limit 10")
    respond_to do |format|
      format.rss
      format.atom
    end
  end

  def nominated
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

end
