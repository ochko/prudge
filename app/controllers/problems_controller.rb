class ProblemsController < ApplicationController
  before_filter :login_required,
                :except => [:index, :list, :search, :show, :text, :feed]

  access_control [:destroy,
                  :nominated] => 'Judge'

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list

  #  @my_solutions = Solution.find(:all :conditions => ["user_id IS "+current_user.id] 
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
    behavior_cache Problem, Solution, :tag => @order  do
      @my_solutions = Solution.find_by_sql(["SELECT * from solutions WHERE correct=1 and user_id=?",current_user.id])
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
    when "type" then ["p.problem_type_id = ? AND c.start < NOW()", params[:query]]
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
    @problem = Problem.find(params[:id], :include => [:problem_type, :languages])
    if @problem.available_to(current_user)
      prepare_relations
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
    @pending_contests = pending_contests
  end

  def create
    @problem = Problem.new(params[:problem])
    @problem.user_id = current_user.id
    if @problem.save
      @problem.add_languages(params[:languages])
      flash[:notice] = 'Бодлогыг үүсгэлээ. Тэстүүдийг оруулна уу?'
      redirect_to :action => 'show', :id => @problem
    else
      render :action => 'new'
    end
  end

  def edit
    @problem = Problem.find(params[:id])
    if @problem.has_permission?(current_user)
      @pending_contests = pending_contests
    else
      flash[:notice] = 'Энэ бодлогыг одоо засаж болохгүй!'
      redirect_to :action => 'list'
      return
    end
  end

  def update
    @problem = Problem.find(params[:id])
    if @problem.has_permission?(current_user)
      if @problem.update_attributes(params[:problem])
        @problem.update_languages(params[:languages])
        flash[:notice] = 'Problem was successfully updated.'
        redirect_to :action => 'show', :id => @problem
      else
        render :action => 'edit'
      end
    else
      flash[:notice] = 'Энэ бодлогыг одоо засаж болохгүй!'
      redirect_to :action => 'list'
      return
    end
  end

  def destroy
    @problem = Problem.find(params[:id])
    if @problem.solutions.size == 0
      @problem.destroy
      redirect_to :action => 'list'
    else
      flash[:notice] = 'Энэ бодлогын хувьд бодолтууд байгаа учраас устгахгүй.'
      redirect_to :action => 'show', :id => @problem
    end
  end

  private
  def pending_contests
    restrict_to 'Judge' do
      Contest.find(:all, :conditions =>
                   ["end >= NOW()"]).collect {|c| [ c.name, c.id ] }
    end
  end

  def prepare_relations
    @attachment = Attachment.
      new({:attachable_id => @problem.id,
           :attachable_type => 'Problem' })
    @attachments = @problem.attachments
  end

end
