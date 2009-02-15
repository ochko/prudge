class LanguagesController < ApplicationController
  layout 'home'
  before_filter :login_required,
                :except => [:index, :list, :show]

  access_control [:new,
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
    behavior_cache Language do
      @languages = Language.all
    end
  end

  def show
    @language = Language.find(params[:id])
  end

  def new
    @language = Language.new
  end

  def create
    @language = Language.new(params[:language])
    if @language.save
      flash[:notice] = 'Language was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @language = Language.find(params[:id])
  end

  def update
    @language = Language.find(params[:id])
    if @language.update_attributes(params[:language])
      flash[:notice] = 'Language was successfully updated.'
      redirect_to :action => 'show', :id => @language
    else
      render :action => 'edit'
    end
  end

  def destroy
    Language.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
