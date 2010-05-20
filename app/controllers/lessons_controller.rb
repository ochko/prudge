# -*- coding: utf-8 -*-
class LessonsController < ApplicationController
  before_filter :require_user,
                :except => [:index, :show]

  before_filter :prepare_wmd, :only => [:edit, :new]

  def index
    @lessons = Lesson.paginate(:page=>params[:page], :include =>[:author],
                               :order => "created_at desc")
    respond_to do |format|
      format.html
      format.js { render :layout => false }
      format.rss { render :layout => false }
    end

  end

  def show
    @lesson = Lesson.find(params[:id])
  end

  def new
    @lesson = Lesson.new
  end

  def create
    @lesson = Lesson.new(params[:lesson])
    @lesson.author_id = current_user.id
    if @lesson.save
      flash[:notice] = 'Lesson was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @lesson = Lesson.find(params[:id])
    return unless validate_ownership?
  end

  def update
    @lesson = Lesson.find(params[:id])
    return unless validate_ownership?
    if @lesson.update_attributes(params[:lesson])
      flash[:notice] = 'Lesson was successfully updated.'
      redirect_to :action => 'show', :id => @lesson
    else
      render :action => 'edit'
    end
  end

  def destroy
    @lesson = Lesson.find(params[:id])
    return unless validate_ownership?
    @lesson.destroy
    redirect_to :action => 'list'
  end

  private
  def validate_ownership?
    if @lesson.author_id == current_user.id
      return true
    else
      if request.xhr?
        render :text=>'Энэ хичээлийг өөр хүн бичсэн.'
      else
        flash[:notice] = 'Энэ хичээлийг бичсэн хүн биш байна.'
        redirect_to :action => 'show', :id => @lesson
      end
      return false
    end
  end

end
