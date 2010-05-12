class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:account, :show, :edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.save do |result|
      if result
        flash[:notice] = "Бүртгэл амжилттай"
        redirect_back_or_default account_url
      else
        render :action => :new
      end
    end
  end

  def edit
    @user = @current_user
  end

  def update
    @user = current_user
    @user.attributes = params[:user]
    @user.save do |result|
      if result
        flash[:notice] = "Мэдээллийг шинэчиллээ!"
        redirect_to account_url
      else
        render :action => 'edit'
      end
    end
  end

  def index
    @users = User.
      paginate_by_sql("SELECT u.login, u.id, u.school, "+
                        "count(s.percent) as solution_count, "+
                        "sum(s.point) as points,  "+
                        "avg(s.time) as avg,  "+
                        "date_format(max(s.created_at), '%y/%m/%d-%H:%i') as last_access,  "+
                        "count(distinct(p.contest_id)) as contest_count  "+
                        "FROM users u  "+
                        "left join solutions s "+
                        "on s.user_id = u.id and s.isbest = 1 "+
                        "left join problems p on s.problem_id = p.id  "+
                        "group by u.login, u.id  "+
                        "order by points DESC, avg ASC" ,
                        :page => params[:page], :per_page=>100,
                        :total_entries => User.count_by_sql('select count(*) from users'))
      @total = Problem.sum('level', :conditions=> "contest_id is not null")

  end

  def account
    if current_user
      redirect_to :action=> 'show', :id => current_user
    else
      store_location
      redirect_to :action=> :login
    end
  end

  def show
    @total = Problem.sum('level', :conditions=> "contest_id is not null")
    @user = User.find(params[:id])
    @contests = @user.contests
    @solutions = @user.solutions
    @problems = @user.problems
    @lessons = @user.lessons
    @standings = []
    @contests.each do |contest|
      numbers, standings = contest.standings
      idx = standings.index( @user )
      @standings << [contest, numbers[idx]] if idx
    end
    
  end

  def auto_complete_for_user_school
    @users = User.
      all(:select => 'DISTINCT(school)',
          :conditions => [ 'LOWER(school) LIKE ?', '%' + params[:user][:school].downcase + '%' ],
          :order => 'school ASC',
          :limit => 20)
    render :inline => "<%= auto_complete_result @users, 'school' %>"
  end

end
