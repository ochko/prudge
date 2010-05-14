class LanguagesController < ApplicationController
  before_filter :require_admin

  def index
    list
    render :action => 'list'
  end

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
