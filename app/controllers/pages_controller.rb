class PagesController < ApplicationController
  before_filter :login_required,
                :except =>[:search, :show]

  access_control [:index,
                  :list,
                  :new,
                  :create,
                  :edit,
                  :destroy,
                  :update] => 'Admin'
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @page_pages, @pages = paginate :pages, :per_page => 20
  end

  def search
    conditions = case params['field']
    when "title" then ["title LIKE ?", "%#{params[:query]}%"]
    when "content" then ["content LIKE ?", "%#{params[:query]}%"]
    when "tags" then ["tags LIKE ?", "% #{params[:query]} %"]
    else ["title <> ''"]
    end

    @page_pages, @pages = paginate :pages,
           :order => "created_at desc",
           :conditions => conditions,
           :per_page=>20

    if request.xml_http_request?
      render :partial => 'list', :layout => false
    else
      render :action =>'list'
    end

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
