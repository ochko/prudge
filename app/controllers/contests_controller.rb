class ContestsController < ApplicationController
  before_filter :login_required,
                :except => [:index, :list, :past, :show, :participant]

  access_control [:new,
                  :create,
                  :edit,
                  :destroy,
                  :update] => 'Judge'
  def index
    list
    if @contests.size == 1
      @contest = @contests.first
      prepare_show
      render :action => 'show'
    else
      render :action => 'list'
    end
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @contests = Contest.
      find_by_sql('select c.*, t.name as type_name, ' +
                  'p.name as prize, s.name as sponsor ' +
                  'from contests c ' +
                  'join contest_types t on c.type_id = t.id ' +
                  'join prizes p on c.prize_id = p.id ' +
                  'join sponsors s on c.sponsor_id = s.id ' +
                  'where c.end > NOW() ' +
                  'order by c.start ASC')
    @title = 'Тэмцээнүүд'
  end

  def past
    @contests = Contest.
      find_by_sql('select c.*, t.name as type_name, ' +
                  'p.name as prize, s.name as sponsor ' +
                  'from contests c ' +
                  'join contest_types t on c.type_id = t.id ' +
                  'join prizes p on c.prize_id = p.id ' +
                  'join sponsors s on c.sponsor_id = s.id ' +
                  'where c.end < NOW() ' +
                  'order by c.start DESC')
    @title = 'Өнгөрсөн тэмцээнүүд'
    render :action => 'list'
  end

  def show
    @contest = Contest.find(params[:id])
    prepare_show
  end

  def new
    @contest = Contest.new
    get_lists
  end

  def create
    @contest = Contest.new(params[:contest])
    if @contest.save
      flash[:notice] = 'Тэмцээнийг үүсгэлээ.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @contest = Contest.find(params[:id])
    get_lists
  end

  def update
    @contest = Contest.find(params[:id])
    if @contest.update_attributes(params[:contest])
      flash[:notice] = 'Тэмцээнийг шинэчлэн хадгаллаа.'
      redirect_to :action => 'show', :id => @contest
    else
      render :action => 'edit'
    end
  end

  def destroy
    Contest.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def participant
    @user = User.find(params[:user])
    contest = Contest.find(params[:contest])
    @solutions = Solution.
      find(:all,
           :from=>'solutions s',
           :select=>'s.*, l.name as language_name, p.name as problem_name, p.point as problem_point',
           :joins=>'join languages l on s.language_id = l.id ' +
                   'join problems p on s.problem_id = p.id',
           :conditions=>["s.user_id = ? AND p.contest_id = ? AND s.created_at < ?",
                         @user.id, contest.id, contest.end],
           :order => 's.created_at desc')
    render :partial=>'solved'
  end

  protected
  def get_lists
    @types = ContestType.find(:all)
    @prizes = Prize.find(:all)
    @sponsors = Sponsor.find(:all)
  end

  private
  def prepare_show
    @problems = Problem.
      find_by_sql(["SELECT p.*, count(s.id) as solution_count, "+
                   "sum(s.correct) as correct_solutions, u.login "+
                   "FROM problems p "+
                   "join contests c on p.contest_id = c.id "+
                   "join users u on p.user_id = u.id "+
                   "left join solutions s on p.id = s.problem_id "+
                   "where p.contest_id = ? group by p.id "+
                   "order by p.point desc, created_at desc",
                   @contest.id])
    @users = User.
      find_by_sql(["SELECT s.user_id as id, u.login, "+
                   "sum(p.point*s.percent) as point, "+
                   "avg(s.avg_time) as avg "+
                   "FROM solutions s "+
                   "join problems p on s.problem_id = p.id "+
                   "join contests c on p.contest_id = c.id "+
                   "join users u on s.user_id = u.id "+
                   "where c.id = ? and s.created_at < c.end "+
                   "group by s.user_id, u.login "+
                   "order by point desc, avg asc",
                  @contest.id])
    if @users.size > 0
    @user = @users.first
    @solutions = Solution.
      find(:all,
           :from=>'solutions s',
           :select=>'s.*, l.name as language_name, p.name as problem_name, p.point as problem_point',
           :joins=>'join languages l on s.language_id = l.id ' +
                   'join problems p on s.problem_id = p.id',
           :conditions=>["s.user_id = ? AND p.contest_id = ? AND s.created_at < ?",
                         @user.id, @contest.id, @contest.end],
           :order => 's.created_at desc')
    end
  end
end
