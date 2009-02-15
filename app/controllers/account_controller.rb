class AccountController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  #include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  #before_filter :login_from_cookie

  before_filter :login_required,
                :only => [:my,
                          :change_password,
                          :set_user_school_name,
                          :set_user_self_intro]

  ssl_required :signup, :login,
               :change_password, :reset_password, :forgot_password

  def auto_complete_for_user_school_name
    @users = User.
      all(:select => 'DISTINCT(school_name)',
          :conditions => [ 'LOWER(school_name) LIKE ?', '%' + params[:user][:school_name].downcase + '%' ],
          :order => 'school_name ASC',
          :limit => 20)
    render :inline => "<%= auto_complete_result @users, 'school_name' %>"
  end

  def signup
    @user = User.new(params[:user])
    @user.activated_at = nil
    return unless request.post?
    @user.save!
    #self.current_user = @user
    #redirect_back_or_default(:controller => '/home', :action => 'welcome')
    #flash[:notice] = "Thanks for signing up!"
    flash[:notice] = "Мэйл хаягаар тань идэвхжүүлэх кодыг илгээх болно. 10 минутын дараа мэйлээ шалгана уу?"
    redirect_to(:controller => '/home', :action => 'welcome')
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      Interlock.invalidate(caching_key(:all, 'online'))
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => '/home', :action => 'welcome')
    else
      flash[:notice] = "Логин хийж чадсангүй"
    end
  end

  def logout
    Interlock.invalidate(caching_key(:all, 'online'))
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/home', :action => 'welcome')
  end

  def ranking
    behavior_cache Solution, Problem, User, :tag => (params[:page] || 1) do
      @users = User.
        paginate_by_sql("SELECT u.login, u.id, u.school_name, "+
                        "count(s.percent) as solution_count, "+
                        "sum(p.point*s.percent) as points,  "+
                        "avg(s.avg_time) as avg,  "+
                        "date_format(max(s.created_at), '%y/%m/%d-%H:%i') as last_access,  "+
                        "count(distinct(p.contest_id)) as contest_count  "+
                        "FROM users u  "+
                        "left join solutions s "+
                        "on s.user_id = u.id and s.isbest = 1 "+
                        "left join problems p on s.problem_id = p.id  "+
                        "where u.activation_code is null "+
                        "group by u.login, u.id  "+
                        "order by points DESC, avg ASC" ,
                        :page => params[:page], :per_page=>100,
                        :total_entries => User.count_by_sql('select count(*) from users where activation_code is null'))
      @total = Problem.sum('point', :conditions=> "contest_id is not null")
    end
  end

  def my
    if logged_in?
      redirect_to :action=> 'show', :id => current_user
    else
      redirect_to :action=> :login
      return
    end
  end

  def show
    behavior_cache Solution, Problem, User => :id do
    @total = Problem.sum('point', :conditions=> "contest_id is not null")
    @user = User.
      find_by_sql(["SELECT u.*, count(s.id) as solution_count, "+
                  "sum(p.point*s.percent) as points, "+
                  "avg(s.avg_time) as avg, "+
                  "max(s.created_at) as last_access, "+
                  "count(distinct(p.contest_id)) as contest_count "+
                  "FROM users u "+
                  "left join  solutions  s "+
                  "on s.user_id = u.id and s.isbest = 1 "+
                  "left join problems p on s.problem_id = p.id "+
                  "WHERE u.id = ? "+
                  "group by u.id ", params[:id]]).first

    if @user.school_name.blank? or !@user.school_name
      if logged_in? and current_user.id == @user.id
        @user.school_name = 'Энд дарж оруулна уу...'
      else
        @user.school_name = 'Оруулаагүй...'
      end
    end
    if @user.self_intro.blank? or !@user.self_intro
      if logged_in? and current_user.id == @user.id
        @user.self_intro = 'Энд дарж оруулна уу...'
      else
        @user.self_intro = 'Оруулаагүй...'
      end
    end
    @contests = @user.contests
    @solutions = @user.solutions
    @problems = @user.problems
    @lessons = @user.lessons
    @standings = { }
    for contest in @contests
      users = User.
        find_by_sql(["SELECT s.user_id as id, "+
                     "sum(p.point*s.percent) as point, "+
                     "avg(s.avg_time) as avg FROM solutions s "+
                     "join problems p on s.problem_id = p.id "+
                     "join contests c on p.contest_id = c.id "+
                     "where c.id = ? and s.created_at < c.end "+
                     "group by s.user_id "+
                     "order by point desc, avg asc",
                     contest.id])
      num = 0
      point = 0
      avg = 0
      users.each{ |user|
        if point != user.point
          point = user.point
          num += 1
        elsif (user.avg.to_f > avg.to_f + 0.1)
          point = user.point
          num += 1
        end
        avg = user.avg
        if user.id == @user.id
          @standings[contest.id] = num
        end
      }
    end
    end
  end

  def activate
    if params[:activation_code]
      @user = User.find_by_activation_code(params[:activation_code])
      if @user and @user.activate
        self.current_user = @user
        flash[:notice] = "Your account has been activated."
      else
        flash[:error] = "Unable to activate the account.  Did you provide the correct information?"
      end
    elsif params[:id]
      @user = User.find_by_activation_code(params[:id])
      if @user and @user.activate
        self.current_user = @user
        flash[:notice] = "Your account has been activated"
      end
    else
      flash.clear
    end
    redirect_to(:controller => '/home', :action => 'welcome')
  end

  def change_password
    return unless request.post?
    if User.authenticate(current_user.login, params[:old_password])
      if ((params[:password] == params[:password_confirmation]) &&
          params[:password_confirmation] != nil &&
          params[:password_confirmation] != '')
        current_user.password_confirmation = params[:password_confirmation]
        current_user.password = params[:password]
        flash[:notice] = current_user.save ?
              "Password changed" :
              "Password not changed"
      else
        flash[:notice] = "Password mismatch"
        @old_password = params[:old_password]
      end
    else
      flash[:notice] = "Wrong password"
    end
  end

  def forgot_password
    return unless request.post?
    if @user = User.find_by_email(params[:email])
      @user.forgot_password
      @user.save
      redirect_back_or_default(:controller => '/home', :action => 'welcome')
      flash[:notice] = "Нууц үг сэргээх холбоосыг мэйл хаягаар тань явуулсан. Шалгана уу?"
    else
      flash[:notice] = "Ийм мэйл хаягаар бүртгүүлээгүй байна."
    end
  end

  def reset_password
    @user = User.find_by_password_reset_code(params[:id])
    raise if @user.nil?
    return if @user unless params[:password]
      if (params[:password] == params[:password_confirmation])
        self.current_user = @user #for the next two lines to work
        current_user.password_confirmation = params[:password_confirmation]
        current_user.password = params[:password]
        @user.reset_password
        flash[:notice] = current_user.save ? "Password reset" : "Password not reset"
      else
        flash[:notice] = "Password mismatch"
      end
      redirect_back_or_default(:controller => '/home', :action => 'welcome')
  rescue
    logger.error "Invalid Reset Code entered"
    flash[:notice] = "Sorry - That is an invalid password reset code. Please check your code and try again. (Perhaps your email client inserted a carriage return?"
    redirect_back_or_default(:controller => '/home', :action => 'welcome')
  end

  def set_user_school_name
    user = User.find(params[:id])
    if user.id != current_user.id
      return
    end
    user.school_name = params[:value]
    user.save
    user.reload
    render :text => user.school_name
  end

  def set_user_self_intro
    user = User.find(params[:id])
    if user.id != current_user.id
      return
    end
    user.self_intro = params[:value]
    user.save
    user.reload
    render :text => user.self_intro
  end
end
