class TasksController < ApplicationController
  include FulfillmentsHelper
  helper :fulfillments
  before_filter :login_required

  access_control [:new,
                  :create,
                  :edit,
                  :close,
                  :destroy,
                  :update] => 'Subscriber'
  def index
    if is_subscriber?
      @tasks = Task.find(:all,
                         :from=>"tasks t",
      :joins => "LEFT JOIN fulfillments f ON t.id = f.task_id "+
        "join users u on t.subscriber_id = u.id",
      :select => "t.*, u.login, sum(f.earnings) as earnings, "+
                         "(t.price - earnings) as remainder ",
      :conditions =>["t.subscriber_id = ?",
                     current_user.id],
      :group => 't.id')
      @title = 'Миний санал болгосон ажлууд'
      if @tasks.size > 0
        render :action => 'my_tasks'
      else
        list
        render :action => 'list'
      end
    else
      @task_pages, @tasks = paginate :tasks,
      :per_page => 20,
      :joins => "JOIN fulfillments f ON tasks.id = f.task_id "+
        "join users u on tasks.subscriber_id = u.id",
      :conditions =>["f.user_id = ?",current_user.id],
      :select=>"tasks.*, u.login, f.earnings, f.payd"
      @title = 'Миний гүйцэтгэсэн ажлууд'
      if @tasks.size > 0
        render :action => 'my_fulfillments'
      else
        list
        render :action => 'list'
      end
    end
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @task_pages, @tasks = paginate :tasks, :per_page => 20,
    :joins => "join users u on tasks.subscriber_id = u.id",
    :select => "tasks.*, u.login"
    @title = 'Ажлууд'
  end

  def search
    conditions = case params['field']
    when "pricemore" then ["t.price >= ?", params[:query]]
    when "priceless" then ["t.price <= ?", params[:query]]
    when "technology" then ["t.technology LIKE ?", "%#{params[:query]}%"]
    when "subject" then ["t.subject LIKE ?", "%#{params[:query]}%"]
    when "subscriber" then ["u.login LIKE ?", "%#{params[:query]}%"]
    when "outline" then ["t.outline LIKE ?", "%#{params[:query]}%"]
    else ["t.price > 0"]
    end

    order = case params['field']
    when "pricemore" then "t.price asc"
    when "priceless" then "t.price desc"
    when "technology" then "t.technology"
    when "subject" then "t.subject"
    when "subscriber" then "u.login"
    else "t.deadline"
    end

    @tasks = Task.
      find(:all,
           :from => "tasks t",
           :select => "t.*, u.login",
           :joins => "join users u on t.subscriber_id = u.id",
           :order => order,
           :conditions => conditions)

    if request.xml_http_request?
        render :partial => "list", :layout => false
    end

  end


  def show
    @task = Task.find(params[:id])
    @fulfillments = Fulfillment.
      find(:all,
           :joins =>"JOIN users u ON fulfillments.user_id = u.id",
           :select=>"fulfillments.*, u.login",
           :conditions=>["task_id = ?", @task.id])
    prepare_relations
  end

  def my
    if is_subscriber?
      @tasks = Task.find(:all,
                         :from=>"tasks t",
      :joins => "LEFT JOIN fulfillments f ON t.id = f.task_id "+
        "join users u on t.subscriber_id = u.id",
      :select => "t.*, u.login, sum(f.earnings) as earnings, "+
                         "(t.price - earnings) as remainder ",
      :conditions =>["t.subscriber_id = ?",
                     current_user.id],
      :group => 't.id')
      @title = 'Миний санал болгосон ажлууд'
      render :action => 'my_tasks'
    else
      @task_pages, @tasks = paginate :tasks,
      :per_page => 20,
      :joins => "JOIN fulfillments f ON tasks.id = f.task_id "+
        "join users u on tasks.subscriber_id = u.id",
      :conditions =>["f.user_id = ?",current_user.id],
      :select=>"tasks.*, u.login, f.earnings, f.payd"
      @title = 'Миний гүйцэтгэсэн ажлууд'
      render :action => 'my_fulfillments'
    end

  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(params[:task])
    @task.subscriber_id = current_user.id
    if @task.save
      flash[:notice] = 'Ажил үүсгэгдлээ.'
      redirect_to :action => 'my'
    else
      render :action => 'new'
    end
  end

  def edit
    @task = Task.find(params[:id])
    if !@task.has_permission?(current_user)
      flash[:notice] = 'Зөвхөн өөрийнхөө ажлыг засах боломжтой.'
      redirect_to :action => 'my'
      return
    end
  end

  def update
    @task = Task.find(params[:id])
    if !@task.has_permission?(current_user)
      flash[:notice] = 'Зөвхөн өөрийнхөө ажлыг засах боломжтой.'
      redirect_to :action => 'my'
      return
    end
    if @task.update_attributes(params[:task])
      flash[:notice] = 'Task was successfully updated.'
      redirect_to :action => 'show', :id => @task
    else
      render :action => 'edit'
    end
  end

  def close
    @task = Task.find(params[:id])
    if !@task.has_permission?(current_user)
      flash[:notice] = 'Зөвхөн өөрийнхөө ажлыг хаах боломжтой.'
    else
      @task.finished!
    end
    redirect_to :action => 'my'
  end

  def destroy
    @task = Task.find(params[:id])
    if !@task.has_permission?(current_user)
      flash[:notice] = 'Зөвхөн өөрийнхөө ажлыг устгах боломжтой.'
    else
      @task.destroy
    end
    redirect_to :action => 'my'
  end

  private
  def is_subscriber?
    if current_user.
        roles.map{ |role| role.title.downcase}.
        include?('subscriber')
      return true
    end
    return false
  end

  def prepare_relations
    @attachment = Attachment.
      new({:attachable_id => @task.id,
           :attachable_type => 'Task' })
    @attachments = @task.attachments
  end

end
