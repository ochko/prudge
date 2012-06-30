class SolutionsController < ApplicationController
  before_filter :login_required,
                :except=> [:tryed, :completed, :best]

  access_control [:delete,
                  :inspect,
                  :list] => 'Judge',
                 [:check_best_of_all] => 'Admin'

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :my }

  def list
    conditions = case params['field']
    when "user" then ["u.login LIKE ?", "%#{params[:query]}%"]
    when "lang" then ["l.name = ?", "#{params[:query]}"]
    when "prob" then ["p.name LIKE ?", "%#{params[:query]}%"]
    when "file" then ["s.filename LIKE ?", "%#{params[:query]}%"]
    else ["s.user_id > 0"]
    end

    @solutions = Solution.
      find(:all,
           :from => "solutions s",
           :select => "s.*, p.name as pname, u.login as ulogin, l.name as lname",
           :joins => "join problems p on s.problem_id = p.id "+
                     "join contests c on p.contest_id = c.id "+
                     "join users u on s.user_id = u.id " +
                     "join languages l on s.language_id = l.id ",
           :order => "s.updated_at desc",
           :conditions => conditions,
           :limit => 40)

    if request.xml_http_request?
        render :partial => "list", :layout => false
    end
  end

  def my
    @solutions = Solution.
      find_by_sql(["SELECT s.* FROM solutions s "+
                   "join problems p on s.problem_id = p.id "+
                   "join contests c on p.contest_id = c.id "+
                   "where s.user_id = ? " +
                   "order by s.correct",
                  current_user.id])
  end

  def show
    @solution = Solution.find(params[:id])
    #return unless validate_showable?
    @problem = @solution.problem
    @results = @solution.results.sort{ |x,y| x.test.hidden.to_s <=> y.test.hidden.to_s}
    @title = 'Бодолт'
    if is_judge?
      render :action => 'inspect'
    end
  end

  def best
    @solution = Solution.
      find(:first,
           :conditions=>["problem_id = ? AND correct = 1",
                         params[:problem_id]],
           :order => 'avg_time')
    if @solution.nil?
      flash[:notice] = 'Энэ бодлогыг одоогоор нэг ч хүн бодоогүй байна. Та бодож чадах уу? :)'
      redirect_to :controller=>'problems', :action=>'show',
                  :id =>params[:problem_id]
      return
    end

    @problem = @solution.problem
    @results = @solution.results
    @title = 'Шилдэг бодолт'
    render :action=>'show'
  end

  def tryed
    @solutions = Solution.
      find(:all,
           :from=>'solutions s',
           :select=>'s.*, l.name as language_name, u.login as user_login',
           :joins=>'join languages l on s.language_id = l.id ' +
                   'join users u on s.user_id = u.id',
           :conditions=>["s.problem_id = ?",
                         params[:problem_id]],
           :order => 's.updated_at desc')
    if @solutions.empty?
      render :text => 'Энэ бодлогыг одоогоор нэг ч хүн бодоогүй байна. Та бодож чадах уу? :)'
      return
    end
    render :partial => 'list_for_problem', :locals=>{ :list_title=>'Нийт бодолт'}
  end

  def completed
    @solutions = Solution.
      find(:all,
           :from=>'solutions s',
           :select=>'s.*, l.name as language_name, u.login as user_login',
           :joins=>'join languages l on s.language_id = l.id ' +
                   'join users u on s.user_id = u.id',
           :conditions=>["s.problem_id = ? AND s.correct=1",
                         params[:problem_id]],
           :order => 's.updated_at desc')
    if @solutions.empty?
      render :text => 'Энэ бодлогыг одоогоор нэг ч хүн зөв бодоогүй байна. Та бодож чадах уу? :)'
      return
    end
    render :partial => 'list_for_problem',
           :locals=>{ :list_title=>'Зөв бодолт'}

  end

  def other
    @solutions = Solution.
      find(:all,
           :from=>'solutions s',
           :select=>'s.*, l.name as language_name, u.login as user_login',
           :joins=>'join languages l on s.language_id = l.id ' +
           'join users u on s.user_id = u.id',
           :conditions=>["s.problem_id = ? AND s.correct=1 AND s.user_id <> ?",
                         params[:problem_id], current_user.id],
           :order => 's.avg_time')
    if @solutions.empty?
      render :text => 'Энэ бодлогыг одоогоор өөр хүн зөв бодоогүй байна. Мундаг юмаа :)'
      return
    end
    @solution = Solution.find(params[:solution_id])
    @in_contest = false
    if @solution.created_at < @solution.problem.contest.end and
        Time.now() < @solution.problem.contest.end
      @in_contest = true
      render :text => 'Тэмцээний үеэр бодолтыг харж болохгүй'
    else
      render :partial => 'list_of_solved'
    end
    
  end

  def view
    @solution = Solution.find(params[:id])
    if @solution.user_id == current_user.id
      send_file @solution.public_filename
    else
      flash[:notice] = 'Уучлаарай, тэмцээн дуусаагүй байхад бодолтыг харж болохгүй!.'
      redirect_to :controller=>'contests', :action=>'show',
      :id=> @solution.problem.contest_id
    end
  end

  def source
    @other = Solution.find(params[:other_id])
    @my = Solution.find(params[:my_id])
    if @my.user_id == current_user.id and
        @my.correct and
        @other.problem_id == @my.problem_id
      if @my.created_at < @my.problem.contest.end and
          Time.now() < @my.problem.contest.end
        @my.update_attribute('locked', true)
        send_file @other.public_filename
      else
        flash[:notice] = 'Уучлаарай, Тэмцээний үеэр бодолт харж болохгүй.'
        redirect_to :controller=>'solutions', :action=>'show',
        :id=> @my.id
      end
    else
      flash[:notice] = 'Уучлаарай, бодолтыг харах боломжгүй байна.'
      redirect_to :controller=>'solutions', :action=>'show',
      :id=> @my.id
    end
  end

  def new
    if params[:solution].nil?
      redirect_to :action => 'my'
      return
    end
    @problem = Problem.find(params[:solution]['problem_id'])
    @solution = Solution.
      find(:first, :conditions =>
           ["problem_id = ? AND user_id = ?",
            params[:solution]['problem_id'],
            current_user.id],
           :order=>'created_at DESC')
    if @solution.nil? or
        (@solution.created_at < @problem.contest.end and
         @solution.problem.contest.end < Time.now())
      @solution = Solution.new
      @solution.problem_id = @problem.id
      return unless validate_solvable?
      prepare_select
    else
      @results = @solution.results.sort{ |x,y| x.test.hidden.to_s <=> y.test.hidden.to_s}
      @title = 'Бодолт'
      render :action => 'show'
    end
  end

  def create
    @solution = Solution.new(params[:solution])
    return unless validate_solvable?
    return unless validate_language?
    @solution.user_id = current_user.id
    @existing_solution = Solution.
      find(:first, :conditions =>
           ["problem_id = ? AND user_id = ?",
            @solution.problem_id,
            @solution.user_id],
           :order=>'created_at DESC')
    if !@existing_solution.nil?
      if @existing_solution.user_id == current_user.id and
          (@existing_solution.created_at > @existing_solution.problem.contest.end or
           @existing_solution.problem.contest.end > Time.now())
        @solution.id = @existing_solution.id
        @solution.created_at = @existing_solution.created_at
        #return unless validate_touchable?
        @existing_solution.destroy
      end
    end
    if @solution.save
      flash[:notice] = 'Бодолтыг хадгалж авлаа.'
      redirect_to :action => 'show', :id => @solution
    else
      prepare_select
      render :action => 'new'
    end
  end

  def edit
    @solution = Solution.find(params[:id])
    return unless validate_solvable?
    return unless validate_touchable?
    prepare_select
  end

  def update
    @solution = Solution.find(params[:id])
    return unless validate_solvable?
    return unless validate_touchable?
    return unless validate_language?
    @solution.destroy
    @solution_new = Solution.new(params[:solution])
    @solution_new.user_id = current_user.id
    @solution_new.id = @solution.id
    @solution_new.created_at = @solution.created_at
    if @solution_new.save
      flash[:notice] = 'Бодолт шинэчлэгдлээ.'
      redirect_to :action => 'show', :id => @solution_new
    else
      prepare_select
      render :action => 'edit'
    end
  end

  def destroy
    @solution = Solution.find(params[:id])
    return unless validate_touchable?
    @solution.destroy
    redirect_to :action => 'my'
  end

  def delete
    @solution = Solution.find(params[:id])
    @solution.destroy
    redirect_to :action => 'list'
  end

  def check
    @solution = Solution.find(params[:id])
    if !is_judge?
      if @solution.checked
        render :text => 'Шалгачихсан'
        return
      end

      if @solution.user_id != current_user.id
        render :text => 'Бусдын бодлогыг шалгах шаардлагагүй!'
        return
      end
    end
    if @solution.problem.problem_tests.size == 0
      render :text => 'Шалгах тэст байхгүй байна.'
      return
    end

    do_check
  end

  def check_best_of_all
    Solution.all.each{ |s| s.check_best}
    redirect_to :controller=>:account, :action=>:ranking
  end

  private

  def do_check
    chroot_dir = "#{RAILS_ROOT}/judge/test"

    FileUtils.cd(chroot_dir) do |dir|
      @language = @solution.language
      test_dir = './' + @solution.id.to_s
      if !File.exist?(test_dir)
        FileUtils.mkdir(test_dir)
      else
        FileUtils.rm Dir.glob(test_dir+'/*')
      end
      ENV['PATH'] = '/usr/bin:/bin:/usr/local/bin'

      prog_name = @solution.filename.split('.')[0]
      if system(@language.compiler %
                [@solution.public_filename,
                 test_dir+'/'+prog_name,
                 prog_name] +
                " 2>#{test_dir}/compile.err")

        problem =@solution.problem
        @tests = problem.problem_tests
        real_tests_number = 0
        @tests.each{ |t| real_tests_number+=1 if t.hidden }
        Result.destroy_all("solution_id = #{@solution.id}")
        correct = 0.0
        time = 0.0
        for test in @tests
          input = File.new(test_dir + '/input', 'w')
          input.write(test.input.gsub(/\r/,''))
          input.close()

          system("cat #{test_dir}/input | "+
                 "../safeexec "+
                 "--cpu #{problem.time + @language.time_req} "+
                 "--mem #{problem.memory + @language.mem_req} "+
                 "--chroot #{chroot_dir} " +
                 "--rundir #{@solution.id} "+
                 "--exec #{prog_name} "+
                 "1> #{test_dir}/output " +
                 "2> #{test_dir}/usage ")

          output = IO.read("#{test_dir}/output")

          usage=parse_usage(IO.readlines("#{test_dir}/usage"))

          matched = false
          orig = File.new(test_dir + '/orig', 'w')
          orig.write(test.output.gsub(/\r/,''))
          orig.close()
          system("diff -b #{test_dir}/output #{test_dir}/orig > #{test_dir}/diff")
          diff=IO.readlines("#{test_dir}/diff")
          if diff.size == 0
            matched = true
          end
          FileUtils.rm_f "#{test_dir}/orig"
          FileUtils.rm_f "#{test_dir}/diff"
          result = Result.new()
          result.solution_id = @solution.id
          result.test_id = test.id
          result.status = usage[0]
          result.time = usage[1]
          result.memory = usage[2]
          result.output = output
          result.matched = matched
          result.save()

          if matched
            correct += 1 if test.hidden
            time+=result.time
          else
            break;
          end
        end

        @solution.
          update_results(true,
                         real_tests_number == correct,
                         correct/real_tests_number,
                         time/real_tests_number)
        @results = @solution.results.sort{ |x,y| x.test.hidden.to_s <=> y.test.hidden.to_s}
        if correct.to_i == real_tests_number
          FileUtils.rm_r(test_dir)
        end
        render :partial => 'results/list'
      else
        compile_error = IO.read("#{test_dir}/compile.err")
        render :text => '<b>Компайл хийж чадсангүй:</b><br />' +
          compile_error.gsub(/\/[^\s]+\//,'')
      end
    end
  end

  def no_new_line(diff)
    if diff.size == 3
      if !diff[2].index('No newline at end of file').nil?
        return true
      end
    end
    return false
  end

  def validate_solvable?
    if @solution.problem.user.id == current_user.id and
        @solution.problem.contest.end > Time.now()
      flash[:notice] = 'Уучлаарай, өөрийнхөө дэвшүүлсэн бодлогыг тэмцээн дууссаны дараа л бодож болно!.'
      redirect_to :controller=>'contests', :action=>'show',
                  :id=> @solution.problem.contest_id
      return false
    elsif @solution.problem.contest.start > Time.now()
      flash[:notice] = 'Ирээдүйд болох тэмцээний бодлогыг бодож болохгүй!.'
      redirect_to :controller=>'contests', :action=>'show',
                  :id=> @solution.problem.contest_id
      return false
    elsif @solution.problem.contest.end < Time.now()
      return true
    elsif !@solution.problem.contest.category.eql?('none')
      @user = User.
      find_by_sql("SELECT u.*, count(s.id) as solution_count, "+
                  "sum(p.point*s.percent) as points, "+
                  "avg(s.avg_time) as avg, "+
                  "max(s.created_at) as last_access, "+
                  "count(distinct(p.contest_id)) as contest_count "+
                  "FROM users u "+
                  "left join "+
                  "(select max(percent) as percent, avg(avg_time) as avg_time,  "+
                  "max(created_at) as created_at, user_id, problem_id, id  "+
                  "from  solutions  "+
                  "group by user_id, problem_id) s  "+
                  "on s.user_id = u.id  "+
                  "left join problems p on s.problem_id = p.id "+
                  "WHERE u.id = #{current_user.id} "+
                  "group by u.id ").first
      @total = Problem.sum('point', :conditions=> "contest_id is not null")
      fence = case @solution.problem.contest.category
                when "advanced" then @total
                when "intermediate" then 0.6*@total
                when "beginner" then 0.3*@total
                when "challenger" then 0.05*@total
                else @total
              end
      if @user.points.to_f > fence
        flash[:notice] = 'Таны түвшин энэ тэмцээнийхээс дээгүүр байна.'
        redirect_to :controller=>'contests', :action=>'show',
                    :id=> @solution.problem.contest_id
        return false
      else
        return true
      end
    else
      return true
    end
  end

  def validate_showable?
    if @solution.problem.contest.end < Time.now or
        @solution.user_id == current_user.id
      return true
    else
      flash[:notice] = 'Уучлаарай, тэмцээн дуусаагүй байхад бодолтыг харж болохгүй!.'
      redirect_to :controller=>'contests', :action=>'show',
      :id=> @solution.problem.contest_id
      return false
    end
  end

  def validate_touchable?
    if @solution.user_id != current_user.id
      flash[:notice] ='Бусдын бодолтыг өөрчилж болохгүй!'
      redirect_to :controller=>'problems', :action=>'show',
                  :id => @solution.problem_id
      return false
    elsif @solution.locked
      flash[:notice] ='Энэ бодолтыг өөрчилж болохгүй'
      redirect_to :controller=>'solutions', :action=>'show',
                  :id=> @solution.id
      return false
    elsif @solution.created_at < @solution.problem.contest.end and
        @solution.problem.contest.end < Time.now()
      flash[:notice] ='Тэмцээн дууссан хойно бодолтыг өөрчилж болохгүй!'
      redirect_to :controller=>'contests', :action=>'show',
                  :id=> @solution.problem.contest_id
      return false
    end
    true
  end

  def validate_language?
    if @solution.problem.languages.size == 0
      return true
    end
    if !@solution.problem.languages.map{ |l| l.id}.include?(@solution.language_id)
      flash[:notice] = 'Энэ хэл дээр бодож болохгүй!.'
      redirect_to :controller=>'problems', :action=>'show',
                  :id=> @solution.problem_id
      return false
    end
    true
  end

  def parse_usage(str)
    status = str[0]
    time = str[-1].sub('cpu usage: ','').sub(' miliseconds','')
    memory = str[-2].sub('memory usage: ','').sub(' kbytes','')
    [status, time, memory]
  end

  def prepare_select
    @languages = @solution.problem.languages.
      collect{ |l| [l.name, l.id]}
    if @languages.size == 0
      @languages = Language.find(:all).
        collect{ |l| [l.name, l.id]}
    end
  end

end
