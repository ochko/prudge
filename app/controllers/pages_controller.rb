class PagesController < ApplicationController
  before_filter :require_user,
                :except =>[:search, :show]
  before_filter :require_judge,
                :only => [:index, :list, :new, :create, :edit, :destroy, :update]
                              
  def index
    if params[:query]
      conditions = case params['field']
       when "title" then ["title LIKE ?", "%#{params[:query]}%"]
       when "content" then ["content LIKE ?", "%#{params[:query]}%"]
       when "tags" then ["tags LIKE ?", "% #{params[:query]} %"]
       else ["title <> ''"]
       end
      @pages = Page.paginate(:order => "created_at desc",
                             :conditions => conditions,
                             :per_page=>20, :page => params[:page])
    else
      @pages = Page.paginate :page=>params[:page], :per_page => 20
    end
    render(:layout => false) if request.xml_http_request?
  end

  def show
    @page = Page.find(params[:id])
  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(params[:page])
    @page.user_id = current_user.id
    if @page.save
      normalize_tags(@page)
      flash[:notice] = 'Page was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @page = Page.find(params[:id])
  end

  def update
    @page = Page.find(params[:id])
    if @page.update_attributes(params[:page])
      normalize_tags(@page)
      flash[:notice] = 'Page was successfully updated.'
      redirect_to :action => 'show', :id => @page
    else
      render :action => 'edit'
    end
  end

  def destroy
    Page.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
