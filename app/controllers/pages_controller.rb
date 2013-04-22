class PagesController < ApplicationController
  load_and_authorize_resource

  def index
    authorize! :edit, Page
    @pages = Page.page(params[:page]).per(20)

    render(:layout => false) if request.xml_http_request?
  end

  def show
  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(params[:page])
    @page.user_id = current_user.id
    if @page.save
      flash[:notice] = 'Page was successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @page.update_attributes(params[:page])
      flash[:notice] = 'Page was successfully updated.'
      redirect_to :action => 'show', :id => @page
    else
      render :action => 'edit'
    end
  end

  def destroy
    @page.destroy
    redirect_to :action => 'index'
  end
end
