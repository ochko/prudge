class ContestTypesController < ApplicationController
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
    @contest_type_pages, @contest_types = paginate :contest_types, :per_page => 10
  end

  def show
    @contest_type = ContestType.find(params[:id])
  end

  def new
    @contest_type = ContestType.new
  end

  def create
    @contest_type = ContestType.new(params[:contest_type])
    if @contest_type.save
      flash[:notice] = 'ContestType was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @contest_type = ContestType.find(params[:id])
  end

  def update
    @contest_type = ContestType.find(params[:id])
    if @contest_type.update_attributes(params[:contest_type])
      flash[:notice] = 'ContestType was successfully updated.'
      redirect_to :action => 'show', :id => @contest_type
    else
      render :action => 'edit'
    end
  end

  def destroy
    ContestType.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
