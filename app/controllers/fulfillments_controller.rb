class FulfillmentsController < ApplicationController
  before_filter :login_required

  access_control [:payments,
                  :pay,
                  :list] => 'Accountant'

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @fulfillment_pages, @fulfillments =
      paginate :fulfillments, :per_page => 20,
               :joins => "JOIN tasks t ON fulfillments.task_id = t.id " +
                         "JOIN users u ON fulfillments.user_id = u.id ",
               :select=>"fulfillments.*, t.subject, t.price, u.login"
  end

  def payments
    @fulfillment_pages, @fulfillments =
      paginate :fulfillments, :per_page => 20,
               :joins => "JOIN tasks t ON fulfillments.task_id = t.id " +
                         "JOIN users u ON fulfillments.user_id = u.id ",
               :select=>"fulfillments.*, t.subject, t.price, u.login",
               :conditions=>"fulfillments.earnings > 0"
  end

  def pay
    @fulfillment = Fulfillment.find(params[:id])
    @fulfillment.update_attribute('payd', !@fulfillment.payd)
    @fulfillment = Fulfillment.
      find_by_sql(["SELECT fulfillments.*, t.subject, t.price, u.login FROM fulfillments JOIN tasks t ON fulfillments.task_id = t.id JOIN users u ON fulfillments.user_id = u.id WHERE (fulfillments.id = ?)", params[:id]]).first

    respond_to do |format|
        format.js
    end
  end

  def my
    @task = Task.find(params[:task_id])
    @fulfillment = Fulfillment.find(:first, :conditions=>
                                    ["task_id = ? and user_id =?",
                                     @task.id,
                                     current_user.id])
    if !@fulfillment.nil?
      prepare_relations
      render :action => 'show'
    else
      flash[:notice] = 'Өөр хүний гүйцэтгэлийг үзэж болохгүй!.'
      redirect_to :controller=> 'tasks', :action => 'my'
    end
  end

  def show
    @fulfillment = Fulfillment.find(params[:id])
    if @fulfillment.available_to(current_user)
      @task = @fulfillment.task
      prepare_relations
    else
      flash[:notice] = 'Өөр хүний гүйцэтгэлийг үзэж болохгүй!.'
      redirect_to :controller=> 'tasks', :action => 'my'
      return
    end
  end

  def new
    @task = Task.find(params[:task_id])
    if @task.available_to(current_user)
      @fulfillment = Fulfillment.
        find(:first,:conditions=>["task_id = ? AND user_id = ?",
                                  @task.id,
                                  current_user.id])
      if @fulfillment.nil?
        @fulfillment = Fulfillment.new
        @fulfillment.task_id = @task.id
      else
        prepare_relations
        render :action => 'show'
        return
      end
    else
      flash[:notice] = 'Таны хандсан ажил хаагдсан байна.'
      redirect_to :controller=> 'tasks', :action => 'my'
      return
    end
  end

  def create
    @fulfillment = Fulfillment.new(params[:fulfillment])
    if @fulfillment.task.available_to(current_user)
      @fulfillment.user_id = current_user.id
      if @fulfillment.save
        @fulfillment.task.commited!
        flash[:notice] = 'Файлуудаа хавсаргана уу?'
        redirect_to :action => 'show', :id => @fulfillment
      else
        render :action => 'new'
      end
    else
      flash[:notice] = 'Таны хандсан ажил хаагдсан байна.'
      redirect_to :controller=> 'tasks', :action => 'my'
      return
    end
  end

  def edit
    @fulfillment = Fulfillment.find(params[:id])
    if @fulfillment.has_permission?(current_user)
      @task = @fulfillment.task
    else
      flash[:notice] = 'Өөр хүний гүйцэтгэлийг засаж болохгүй!.'
      redirect_to :controller=> 'tasks', :action => 'my'
      return
    end

  end

  def update
    @fulfillment = Fulfillment.find(params[:id])
    if @fulfillment.has_permission?(current_user)
      if @fulfillment.update_attributes(params[:fulfillment])
        flash[:notice] = 'Гүйцэтгэлийн тайлбарыг хадгалсан.'
        prepare_relations
        redirect_to :action => 'show', :id => @fulfillment
      else
        render :action => 'edit'
      end
    else
      flash[:notice] = 'Өөр хүний гүйцэтгэлийг засаж болохгүй!.'
      redirect_to :controller=> 'tasks', :action => 'my'
      return
    end
  end

  def accept
    @fulfillment = Fulfillment.find(params[:id])
    if @fulfillment.available_to(current_user)
      if @fulfillment.
          update_attributes(params[:fulfillment])
        @fulfillment.task.paid!
        flash[:notice] = 'Гүйцэтгэлийг хүлээн авлаа.'
        prepare_relations
        redirect_to :action => 'show', :id => @fulfillment
      else
        render :action => 'edit'
      end
    else
      flash[:notice] = 'Өөр хүний гүйцэтгэлийг хүлээж авч болохгүй!.'
      redirect_to :controller=> 'tasks', :action => 'my'
      return
    end
  end

  def destroy
    @fulfillment = Fulfillment.find(params[:id])
    if @fulfillment.has_permission?(current_user)
      @fulfillment.destroy
    else
      flash[:notice] = 'Өөр хүний гүйцэтгэлийг устгаж болохгүй!.'
    end
    redirect_to :controller=> 'tasks', :action => 'my'
  end

  private
  def prepare_relations
    @attachment = Attachment.
      new({:attachable_id => @fulfillment.id,
           :attachable_type => 'Fulfillment' })
    @attachments = @fulfillment.attachments
  end

end
