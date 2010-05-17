class PagesController < ApplicationController
  before_filter :require_user,
                :except => :show
  before_filter :require_judge,
                :only => [:index, :list, :new, :create, :edit, :destroy, :update]
                              
  def index
    @pages = Page.paginate :page=>params[:page], :per_page => 20
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
