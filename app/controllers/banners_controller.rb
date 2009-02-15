class BannersController < ApplicationController
  before_filter :login_required,
                :except => [:click, :new, :create, :show]

  access_control [:list,
                  :edit,
                  :destroy,
                  :update] => 'Admin'

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @banner_pages, @banners = paginate :banners, :per_page => 30,
    :conditions=>["parent_id is null"]
  end

  def show
    @banner = Banner.find(params[:id])
  end

  def new
    @banner = Banner.new
  end

  def create
    @banner = Banner.new(params[:banner])
    @banner.enabled = false
    if @banner.save
      flash[:notice] = 'Баннерийг амжилттай хадгалж авлаа. Одоо та холбоо бариснаар баннераа идэвхжүүлэх үлдлээ.'
      redirect_to :action => 'show', :id => @banner
    else
      render :action => 'new'
    end
  end

  def edit
    @banner = Banner.find(params[:id])
  end

  def update
    @banner = Banner.find(params[:id])
    if @banner.update_attributes(params[:banner])
      flash[:notice] = 'Banner was successfully updated.'
      redirect_to :action => 'show', :id => @banner
    else
      render :action => 'edit'
    end
  end

  def click
    @banner = Banner.find(params[:id])
    @banner.update_attributes(params[:banner])
    @banner.increment!('clicks')
    redirect_to @banner.address
  end

  def destroy
    Banner.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
