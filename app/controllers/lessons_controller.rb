# -*- coding: utf-8 -*-
class LessonsController < ApplicationController
  before_filter :require_user,
                :except => [:index, :list, :search, :show, :get_homeworks, :feed]

  auto_complete_for :problem, :name

  def index
    @lessons = Lesson.paginate(:page=>params[:page], :include =>[:author],
                               :order => "created_at desc")
    render(:layout => false) if request.xml_http_request?
  end

  def feed
    @lessons = Lesson.find(:all,
                           :select => "lessons.*, u.login",
                           :joins => "join users u on lessons.author_id = u.id",
                           :order => "created_at desc ",
                           :limit => 10)
    respond_to do |format|
      format.rss
      format.atom
    end
  end

  def show
    @lesson = Lesson.find(params[:id])
    @problems = @lesson.problems
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
    @problems = @lesson.problems
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

  def get_homeworks
    @lesson = Lesson.find(params[:lesson])
    @problems = @lesson.problems
    render :partial => 'homework', :layout =>false
  end

  def list_homeworks
    @lesson = Lesson.find(params[:lesson])
    @problems = @lesson.problems
    render :partial => 'homework_just_list', :layout =>false
  end

  def add_homework
    @lesson = Lesson.find(params[:id])
    return unless validate_ownership?
    @problem = Problem.
      find(:first, :conditions => ['name = ?',
                                   params[:problem][:name]])
    if @problem
      @lesson.problems << @problem
    end
    @problems = @lesson.problems

    render :partial => 'problems', :layout => false
  end

  def remove_homework
    @lesson = Lesson.find(params[:id])
    return unless validate_ownership?
    @problem = Problem.find(params[:problem])
    if @problem
      Homework.
        find(:first,
             :conditions => ['lesson_id = ? and problem_id = ?',
                            @lesson.id, @problem.id]).
        destroy
    end

    @problems = @lesson.problems

    render :partial => 'problems', :layout => false
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
