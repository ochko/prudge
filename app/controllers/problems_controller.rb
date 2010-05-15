# -*- coding: utf-8 -*-
class ProblemsController < ApplicationController
  before_filter :require_user,
                :except => [:index, :list, :search, :show, :text, :feed]

  before_filter :require_judge, :only => [:destroy, :nominated]

  def index
    list
    render :action => 'list'
  end

  def list
    @order = params[:order] || "created_at_desc"
    @order.gsub!(/\d/,'')
    order_sql = ''
    order_sql << 'problems.' if @order =~/created/
    if @order =~ /_desc/
      order_sql << @order.sub(/_desc/, ' desc')
    elsif @order =~ /_asc/
      order_sql << @order.sub(/_asc/, ' asc')
    end
    page = params[:page] || '1'
    @order << page
    @my_solutions = []
    @my_solutions = Solution.find_by_sql(["SELECT * from solutions WHERE correct=1 and user_id=?", current_user.id]) if current_user
 
    @problems = Problem.
        paginate(:page => params[:page], :per_page => 30,
             :select => "problems.*, u.login as login, count(s.id) as solution_count, "+
             "sum(s.correct) as correct_count",
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

  def search
    conditions = case params['field']
    when "name" then ["p.name LIKE ? AND c.start < NOW()", "%#{params[:query]}%"]
    when "text" then ["p.text LIKE ? AND c.start < NOW()", "%#{params[:query]}%"]
    else ["c.start < NOW()"]
    end

    @problems = Problem.
      find(:all,
           :from => "problems p",
           :select => "p.*, u.login as login, count(s.id) as solution_count, "+
           "sum(s.correct) as correct_count",
           :joins => "join contests c on c.id = p.contest_id " +
           "left join users u on p.user_id = u.id " +
           "left join solutions s on p.id = s.problem_id ",
           :order => "contest_id, created_at",
           :conditions => conditions,
           :group => "p.id")

    if request.xml_http_request?
        render :partial => "search", :layout => false
    end

  end

  def nominated
    @problems = Problem.find(:all, :conditions => ["contest_id IS NULL"])
  end

  def show
    @problem = Problem.find(params[:id], :include => [:languages])
    if @problem.available_to(current_user)
      @solution_count = Solution.
        count_by_sql(["SELECT count(*) FROM solutions s where problem_id = ?",
                      @problem.id])
      @solution_correct = Solution.
        count_by_sql(["SELECT count(*) FROM solutions s where problem_id = ? AND correct = true",
                      @problem.id])
      @touchable = @problem.has_permission?(current_user)
    else
      flash[:notice] = 'Энэ бодлогыг одоогоор үзэж болохгүй!'
      redirect_to :action => 'list'
      return
    end
  end

  def new
    @problem = Problem.new
  end

  def create
    params[:problem].delete('contest_id') unless judge?
    @problem = current_user.problems.build(params[:problem])
    if @problem.save
      @problem.add_languages(params[:languages])
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
        @problem.update_languages(params[:languages])
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
