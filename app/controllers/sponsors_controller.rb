class SponsorsController < ApplicationController
  before_filter :login_required,
                :except => [:index, :list, :show]

  access_control [:new,
                  :create,
                  :edit,
                  :destroy,
                  :update] => 'Admin'
  layout 'contests'
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @sponsor_pages, @sponsors = paginate :sponsors, :per_page => 10
  end

  def show
    @sponsor = Sponsor.find(params[:id])
  end

  def new
    @sponsor = Sponsor.new
  end

  def create
    @sponsor = Sponsor.new(params[:sponsor])
    if @sponsor.save
      flash[:notice] = 'Sponsor was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @sponsor = Sponsor.find(params[:id])
  end

  def update
    @sponsor = Sponsor.find(params[:id])
    if @sponsor.update_attributes(params[:sponsor])
      flash[:notice] = 'Sponsor was successfully updated.'
      redirect_to :action => 'show', :id => @sponsor
    else
      render :action => 'edit'
    end
  end

  def destroy
    Sponsor.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
