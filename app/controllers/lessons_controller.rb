class LessonsController < ApplicationController
  before_filter :login_required,
                :except => [:index, :list, :search, :show, :get_homeworks, :feed]

  auto_complete_for :problem, :name

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    behavior_cache Lesson, :tag=> (params[:page] || '1') do
      @lessons = Lesson.
        paginate(:page=>params[:page],
                 :per_page => 5,
                 :include =>[:author],
                 :order => "created_at desc")
    end
  end

  def feed
    @lessons = Lesson.find(:all,
                           :select => "lessons.*, u.login",
                           :joins => "join users u on lessons.author_id = u.id",
                           :order => "created_at desc ",
                           :limit => 10)
    respond_to do |format|
      format.rss
      format.atom
    end
  end

  def search
    conditions = case params['field']
    when "title" then ["l.title LIKE ?", "%#{params[:query]}%"]
    when "text" then ["l.text LIKE ?", "%#{params[:query]}%"]
    when "tags" then ["l.tags LIKE ?", "% #{params[:query]} %"]
    when "author" then ["u.login LIKE ?", "%#{params[:query]}%"]
    else ["l.title <> ''"]
    end

    @lessons = Lesson.
      find(:all,
           :from => "lessons l",
           :select => "l.*, u.login as author_login",
           :joins => "join users u on l.author_id = u.id",
           :order => "updated_at desc",
           :conditions => conditions)

    if request.xml_http_request?
        render :partial => "list", :layout => false
    end

  end

  def show
    @lesson = Lesson.find(params[:id])
    @attachments = @lesson.attachments

    @problems = @lesson.problems
  end

  def new
    @lesson = Lesson.new
    @courses = related_courses
  end

  def create
    @lesson = Lesson.new(params[:lesson])
    @lesson.author_id = current_user.id
    if @lesson.save
      normalize_tags(@lesson)
      flash[:notice] = 'Lesson was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @lesson = Lesson.find(params[:id])
    return unless validate_ownership?
    @courses = related_courses
    @problems = @lesson.problems
    prepare_relations
  end

  def update
    @lesson = Lesson.find(params[:id])
    return unless validate_ownership?
    if @lesson.update_attributes(params[:lesson])
      normalize_tags(@lesson)
      flash[:notice] = 'Lesson was successfully updated.'
      redirect_to :action => 'show', :id => @lesson
    else
      render :action => 'edit'
    end
  end

  def destroy
    @lesson = Lesson.find(params[:id])
    return unless validate_ownership?
    @lesson.destroy
    redirect_to :action => 'list'
  end

  def get_homeworks
    @lesson = Lesson.find(params[:lesson])
    @problems = @lesson.problems
    render :partial => 'homework', :layout =>false
  end

  def list_homeworks
    @lesson = Lesson.find(params[:lesson])
    @problems = @lesson.problems
    render :partial => 'homework_just_list', :layout =>false
  end

  def add_homework
    @lesson = Lesson.find(params[:id])
    return unless validate_ownership?
    @problem = Problem.
      find(:first, :conditions => ['name = ?',
                                   params[:problem][:name]])
    if @problem
      @lesson.problems << @problem
    end
    @problems = @lesson.problems

    render :partial => 'problems', :layout => false
  end

  def remove_homework
    @lesson = Lesson.find(params[:id])
    return unless validate_ownership?
    @problem = Problem.find(params[:problem])
    if @problem
      Homework.
        find(:first,
             :conditions => ['lesson_id = ? and problem_id = ?',
                            @lesson.id, @problem.id]).
        destroy
    end

    @problems = @lesson.problems

    render :partial => 'problems', :layout => false
  end

  private
  def validate_ownership?
    if @lesson.author_id == current_user.id
      return true
    else
      if request.xhr?
        render :text=>'Энэ хичээлийг өөр хүн бичсэн.'
      else
        flash[:notice] = 'Энэ хичээлийг бичсэн хүн биш байна.'
        redirect_to :action => 'show', :id => @lesson
      end
      return false
    end
  end

  def prepare_relations
    @attachment = Attachment.
      new({:attachable_id => @lesson.id,
           :attachable_type => 'Lesson' })
    @attachments = @lesson.attachments
  end

  def related_courses
    current_user.courses.collect{ |c| [c.name, c.id] }
  end

end
