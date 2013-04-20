# -*- coding: utf-8 -*-
class LessonsController < ApplicationController
  menu :lesson

  load_and_authorize_resource

  def index
    @lessons = Lesson.order("created_at desc").
      page(params[:page]).preload(:author)

    respond_to do |format|
      format.html
      format.js { render :layout => false }
      format.rss { render :layout => false }
    end

  end

  def show
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
  end

  def update
    if @lesson.update_attributes(params[:lesson])
      flash[:notice] = 'Lesson was successfully updated.'
      redirect_to :action => 'show', :id => @lesson
    else
      render :action => 'edit'
    end
  end

  def destroy
    @lesson.destroy
    redirect_to :action => 'list'
  end
end
