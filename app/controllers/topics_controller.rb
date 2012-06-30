class TopicsController < ApplicationController
  before_filter :login_required,
                :except => [:index, :list, :search, :show]

  access_control [:new,
                  :create,
                  :edit,
                  :destroy,
                  :update,
                  :moderate] => 'Admin'
  def index
    last
    render :action => 'last'
  end

  def feed
    @comments = Comment.
      find(:all,
           :select => 'u.login, c.*',
           :from => 'comments c',
           :joins => 'join users u on c.user_id = u.id',
           :order => 'created_at desc',
           :limit => 20)
    respond_to do |format|
      format.rss
      format.atom
    end
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
  def moderate
    @comment_pages, @comments =
      paginate(:comments, :per_page => 100,
               :order => 'created_at desc')
  end

  def last
    @comments = Comment.
      paginate(:page => params[:page], :per_page=> 20,
               :order => 'created_at desc',
               :include => [:user])
  end

  def search
    limit = nil
    if params[:query] and params[:query].length > 2
    conditions = case params['field']
    when "text" then ["c.text LIKE ?", "%#{params[:query]}%"]
    when "user" then ["u.login LIKE ?", "%#{params[:query]}%"]
    end
    else
      conditions = ["1"]
      limit = 30
    end
    @comments = Comment.
      find(:all,
           :from => "comments c",
           :select => "c.*, u.login as user_login",
           :joins => "join users u on c.user_id = u.id ",
           :order => "created_at desc",
           :conditions => conditions,
           :limit =>limit)

    if request.xml_http_request?
        render :partial => "search", :layout => false
    end
  end

  def list
    if !params[:type]
      @topics = Topic.
        find(:all,
             :from=>'topics t',
             :joins=>'LEFT JOIN comments c ON t.id = c.topic_id and topic_type = "Topic"',
             :select=>'t.id, t.title as name, count(c.id) as post_count, '+
                    'max(c.created_at) as last_time',
             :group=>'t.id')
      @page_title ='Хэлэлцүүлгүүд'
    elsif params[:type].eql?('contests')
      @topics = Topic.
        find(:all,
             :from=>'contests t',
             :joins=>'LEFT JOIN comments c ON t.id = c.topic_id',
             :select=>'t.id, t.name as name, count(c.id) as post_count, '+
                    'max(c.created_at) as last_time',
             :conditions => 'topic_type = "Contest"',
             :group=>'t.id')
      @type = 'contests'
      @page_title ='Тэмцээний хэлэлцүүлгүүд'
    elsif params[:type].eql?('problems')
      @topics = Topic.
        find(:all,
             :from=>'problems t',
             :joins=>'LEFT JOIN comments c ON t.id = c.topic_id',
             :select=>'t.id, t.name as name, count(c.id) as post_count, '+
                    'max(c.created_at) as last_time',
             :conditions => 'topic_type = "Problem"',
             :group=>'t.id')
      @type = 'problems'
      @page_title ='Бодлогын хэлэлцүүлгүүд'
    elsif params[:type].eql?('lessons')
      @topics = Topic.
        find(:all,
             :from=>'lessons t',
             :joins=>'LEFT JOIN comments c ON t.id = c.topic_id',
             :select=>'t.id, t.title as name, count(c.id) as post_count, '+
                    'max(c.created_at) as last_time',
             :conditions => 'topic_type = "Lesson"',
             :group=>'t.id')
      @type = 'lessons'
      @page_title ='Хичээлийн хэлэлцүүлгүүд'
    elsif params[:type].eql?('tasks')
      @topics = Topic.
        find(:all,
             :from=>'tasks t',
             :joins=>'LEFT JOIN comments c ON t.id = c.topic_id',
             :select=>'t.id, t.subject as name, count(c.id) as post_count, '+
                    'max(c.created_at) as last_time',
             :conditions => 'topic_type = "Task"',
             :group=>'t.id')
      @type = 'tasks'
      @page_title ='Ажлын талаархи хэлэлцүүлгүүд'
    end
  end

  def show
    if !params[:type]
      @topic = Topic.
        find(params[:id],
             :select=>'topics.id, topics.title as name, '+
             'topics.description as description')
      topic_class = 'Topic'
      @type = 'topics'
    elsif params[:type].eql?('contests')
      @topic = Contest.
        find(params[:id],
             :select=>'contests.id, contests.name as name, '+
             'contests.description as description')
      topic_class = 'Contest'
      @type = 'contests'
    elsif params[:type].eql?('problems')
      @topic = Problem.
        find(params[:id],
             :select=>'problems.id, problems.name as name, '+
             'problems.text as description')
      topic_class = 'Problem'
      @type = 'problems'
    elsif params[:type].eql?('lessons')
      @topic = Lesson.
        find(params[:id],
             :select=>'lessons.id, lessons.title as name, '+
             'lessons.text as description')
      topic_class = 'Lesson'
      @type = 'lessons'
    elsif params[:type].eql?('tasks')
      @topic = Task.
        find(params[:id],
             :select=>'tasks.id, tasks.subject as name, '+
             'tasks.outline as description')
      topic_class = 'Task'
      @type = 'tasks'
    elsif params[:type].eql?('topics')
      @topic = Topic.
        find(params[:id],
             :select=>'topics.id, topics.title as name, '+
             'topics.description as description')
      topic_class = 'Topic'
      @type = 'topics'
    end
    @comment = Comment.new('topic_id'=>@topic.id,'topic_type'=>topic_class)
    @comments = Comment.
      paginate(:page=> params[:page], :per_page=>20,
               :conditions=>['topic_id = ? AND topic_type = ?',
                             @topic.id, topic_class],
               :include => [:user],
               :order => 'id DESC')
    @box_title = "#{@comments.total_entries} Коммент"
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(params[:topic])
    if @topic.save
      flash[:notice] = 'Topic was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @topic = Topic.find(params[:id])
  end

  def update
    @topic = Topic.find(params[:id])
    if @topic.update_attributes(params[:topic])
      flash[:notice] = 'Topic was successfully updated.'
      redirect_to :action => 'show', :id => @topic
    else
      render :action => 'edit'
    end
  end

  def destroy
    Topic.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
