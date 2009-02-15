class GroupsController < ApplicationController
  before_filter :login_required
  layout 'courses'
  access_control  [:new,
                   :create,
                   :edit,
                   :destroy,
                   :allow,
                   :deny,
                   :update] => 'Teacher'

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
  :redirect_to => { :action => :list }

  def list
    @groups = Group.find(:all)
  end

  def show
    @group = Group.find(params[:id])
    @members = @group.members
    @requesters = @group.requests
    @course = @group.course
    @lessons = @course.lessons
  end

  def my
    if current_user
      @group = current_user.groups.first
      if @group
        redirect_to :action => 'show', :id=>@group
      else
        flash[:notice] = "Та аль ч ангид элсээгүй байна, ангиа сонгоод элсэнэ үү"
        redirect_to :controller => 'groups', :action => 'list'
      end
    else
      flash[:notice] = "Анги руугаа орохдоо логин хийх шаардлагатай"
      redirect_to :controller=>'account', :action=> 'login'
    end
  end

  def requests
    @group = Group.find(params[:id])
    @requesters = @group.requests
  end

  def new
    @group = Group.new
    @group.course_id = params[:course]
  end

  def create
    @group = Group.new(params[:group])
    if @group.save
      flash[:notice] = 'Анги бүртгэгдлээ.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])
    if @group.update_attributes(params[:group])
      flash[:notice] = 'Ангийн мэдээлэл шинэчлэгдэв.'
      redirect_to :action => 'show', :id => @group
    else
      render :action => 'edit'
    end
  end

  def destroy
    Group.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def enroll
    @group = Group.find(params[:id])
    if @group.memberships.select{ |m| current_user.id == m.user_id}.size == 0
      if @group.isopen
        flash[:notice] = 'Баярлалаа, Элсэх хүсэлтийг тань хадгалж авлаа.
                        Багш таны хүсэлтийг зөвшөөрсний дараа
                        та курсэд нэвтрэх боломжтой болно.'
        @group.requests << current_user
      else
        flash[:notice] = 'Уучлаарай, бүртгэл дууссан байна'
      end
    else
      flash[:notice] = 'Та энэ курсэд элсчихсэн эсвэл элсэх хүсэлт илгээсэн байна'
    end
  end

  def allow
    Membership.
      find(:first,
           :conditions=>['user_id = ? and group_id = ?',
                         params[:user_id],
                         params[:group_id]]).
      update_attribute(:status, true)

    flash[:notice] = 'Оролцогчийг ангид бүртгэж авлаа'
    redirect_to :action=>:show, :id=>params[:group_id]
  end

  def deny
    Membership.
      find(:first,
           :conditions=>['user_id = ? and group_id = ?',
                         params[:user_id],
                         params[:group_id]]).
      destroy

    flash[:notice] = 'Ангид элсэх хүсэлтийг устгалаа'
    redirect_to :action=>:show, :id=>params[:group_id]
  end

  def get_homeworks
    @group = Group.find(params[:group])
    @lesson = Lesson.find(params[:lesson])
    @problems = Problem.
      find_by_sql(["SELECT p.*, m.group_id, count(s1.id) as solution_count, "+
                   "sum(s1.correct) as correct_solutions, u.login "+
                   "FROM problems p "+
                   "join homeworks h on p.id = h.problem_id "+
                   "join users u on p.user_id = u.id "+
                   "left join solutions s on p.id = s.problem_id "+
                   "left join memberships m on (s.user_id = m.user_id and m.group_id =? ) "+
                   "left join solutions s1 on (s.id = s1.id and s1.user_id = m.user_id and m.group_id =?) " +
                   "where h.lesson_id = ? group by p.id "+
                   "order by p.point desc, created_at desc",
                   @group.id, @group.id, @lesson.id])

    @users = User.
      find_by_sql(["select mem.user_id as id, u.login, s.point, s.avg from memberships mem left join (" +
                   "SELECT m.user_id as id, "+
                   "sum(p.point*s.percent) as point, "+
                   "avg(s.avg_time) as avg "+
                   "from memberships m " +
                   "left join solutions s on m.user_id = s.user_id "+
                   "left join problems p on s.problem_id = p.id "+
                   "left join homeworks h on s.problem_id = h.problem_id "+
                   "where h.lesson_id = ? and m.group_id = ? "+
                   "group by m.user_id "+
                   ") as s on mem.user_id = s.id " +
                   "left join users u on mem.user_id = u.id " +
                   "where mem.status = 1 "+
                   "order by point desc, avg asc ",
                  @lesson.id, @group.id])
    render :partial => 'homeworks'
  end

  def get_allhomeworks
    @group = Group.find(params[:group])
    @problems = Problem.
      find_by_sql(["SELECT p.*, m.group_id, count(s1.id) as solution_count, "+
                   "sum(s1.correct) as correct_solutions, u.login "+
                   "FROM problems p "+
                   "join homeworks h on p.id = h.problem_id "+
                   "join contents c on h.lesson_id = c.lesson_id " +
                   "join groups g on c.course_id = g.course_id " +
                   "join users u on p.user_id = u.id "+
                   "left join solutions s on p.id = s.problem_id "+
                   "left join memberships m on (s.user_id = m.user_id and m.group_id = ? and m.status = 1 ) "+
                   "left join solutions s1 on (s.id = s1.id and s1.user_id = m.user_id and m.group_id =?) " +
                   "group by p.id "+
                   "order by p.point desc, created_at desc",
                   @group.id, @group.id])

    @users = User.
      find_by_sql(["select mem.user_id as id, u.login, s.point, s.avg from memberships mem left join (" +
                   "SELECT m.user_id as id, "+
                   "sum(p.point*s.percent) as point, "+
                   "avg(s.avg_time) as avg "+
                   "from memberships m " +
                   "left join solutions s on m.user_id = s.user_id "+
                   "left join problems p on s.problem_id = p.id "+
                   "left join homeworks h on s.problem_id = h.problem_id "+
                   "left join contents c on h.lesson_id = c.lesson_id "+
                   "left join groups g on c.course_id = g.course_id " +
                   "where g.id = ? "+
                   "group by m.user_id "+
                   ") as s on mem.user_id = s.id " +
                   "left join users u on mem.user_id = u.id "+
                   "where mem.status = 1 " +
                   "order by point desc, avg asc ",
                  @group.id])
    render :partial => 'allhomeworks'
  end

  def participant
    @user = User.find(params[:user])
    lesson = Lesson.find(params[:lesson])
    @solutions = Solution.
      find(:all,
           :from=>'solutions s',
           :select=>'s.*, l.name as language_name, p.name as problem_name, p.point as problem_point',
           :joins=>'join languages l on s.language_id = l.id ' +
                   'join problems p on s.problem_id = p.id ' +
                   'join homeworks h on s.problem_id = h.problem_id',
           :conditions=>["s.user_id = ? AND h.lesson_id = ? ",
                         @user.id, lesson.id],
           :order => 's.created_at desc')
    render :partial=>'solved'
  end

  def participant_all_works
    @user = User.find(params[:user])
    group = Group.find(params[:group])
    @solutions = Solution.
      find(:all,
           :from=>'solutions s',
           :select=>'s.*, l.name as language_name, p.name as problem_name, p.point as problem_point',
           :joins=>'join languages l on s.language_id = l.id ' +
                   'join problems p on s.problem_id = p.id ' +
                   'join homeworks h on s.problem_id = h.problem_id ' +
                   'join contents c on h.lesson_id = c.lesson_id ' +
                   'join groups g on c.course_id = g.course_id ' +
                   'join memberships m on s.user_id = m.user_id',
           :conditions=>["s.user_id = ? AND g.id = ? ",
                         @user.id, group.id],
           :order => 's.created_at desc')
    render :partial=>'solved'
  end


end
