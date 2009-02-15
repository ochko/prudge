class PrizesController < ApplicationController
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
    @prize_pages, @prizes = paginate :prizes, :per_page => 10
  end

  def show
    @prize = Prize.find(params[:id])
  end

  def new
    @prize = Prize.new
  end

  def create
    @prize = Prize.new(params[:prize])
    if @prize.save
      flash[:notice] = 'Prize was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @prize = Prize.find(params[:id])
  end

  def update
    @prize = Prize.find(params[:id])
    if @prize.update_attributes(params[:prize])
      flash[:notice] = 'Prize was successfully updated.'
      redirect_to :action => 'show', :id => @prize
    else
      render :action => 'edit'
    end
  end

  def destroy
    Prize.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
