# -*- coding: utf-8 -*-
class LessonsController < ApplicationController
  menu :lesson

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
    return unless touchable?
  end

  def update
    @lesson = Lesson.find(params[:id])
    return unless touchable?
    if @lesson.update_attributes(params[:lesson])
      flash[:notice] = 'Lesson was successfully updated.'
      redirect_to :action => 'show', :id => @lesson
    else
      render :action => 'edit'
    end
  end

  def destroy
    @lesson = Lesson.find(params[:id])
    return unless touchable?
    @lesson.destroy
    redirect_to :action => 'list'
  end

  private
  def touchable?
    if @lesson.touchable_by?(current_user)
      return true
    else
      flash[:notice] = 'Энэ хичээлийг бичсэн хүн биш байна.'
      redirect_to :action => 'show', :id => @lesson
      return false
    end
  end

end
