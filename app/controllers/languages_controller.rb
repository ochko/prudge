class LanguagesController < ApplicationController
  menu :home

  before_filter :require_admin, :except => :index

  def index
    @languages = Language.all
    render(:action => 'list') if admin?
  end

  def new
    @language = Language.new
  end

  def create
    @language = Language.new(params[:language])
    if @language.save
      flash[:notice] = 'Language was successfully created.'
      redirect_to :action => :index
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
      redirect_to :action => :index
    else
      render :action => 'edit'
    end
  end

  def destroy
    Language.find(params[:id]).destroy
    redirect_to :action => :index
  end
end
