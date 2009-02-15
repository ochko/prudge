class CoursesController < ApplicationController
  before_filter :login_required, :except=> [:index, :list, :show]

  access_control  [:new,
                   :create,
                   :edit,
                   :destroy,
                   :update] => 'Teacher'

  auto_complete_for :problem, :name
  auto_complete_for :lesson, :title

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
  :redirect_to => { :action => :list }

  def list
    @courses = Course.find(:all)
  end

  def show
    @course = Course.find(params[:id])
    @lessons = @course.lessons
    @groups = @course.groups
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(params[:course])
    @course.teacher_id = current_user.id
    if @course.save
      flash[:notice] = 'Курсыг үүсгэв.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @course = Course.find(params[:id])
  end

  def update
    @course = Course.find(params[:id])
    if @course.update_attributes(params[:course])
      flash[:notice] = 'Курсыг шинэчлэн хадгалав.'
      redirect_to :action => 'show', :id => @course
    else
      render :action => 'edit'
    end
  end

  def destroy
    Course.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def add_lesson
    @course = Course.find(params[:id])
    return unless validate_ownership?
    @lesson = Lesson.
      find(:first, :conditions => ['title = ?',
                                   params[:lesson][:title]])
    if @lesson
      @course.lessons << @lesson
    end
    @lessons = @course.lessons

    render :partial => 'lessons'
  end

  def remove_lesson
    @course = Course.find(params[:id])
    return unless validate_ownership?
    @lesson = Lesson.find(params[:lesson])
    if @lesson
      Content.
        find(:first,
             :conditions => ['course_id = ? and lesson_id = ?',
                            @course.id, @lesson.id]).
        destroy
    end

    @lessons = @course.lessons

    render :partial => 'lessons'
  end

  private
  def validate_ownership?
    if @course.teacher_id == current_user.id
      return true
    else
      if request.xhr?
        render :text=>'Энэ курсын багш нь өөр хүн байна.'
      else
        flash[:notice] = 'Энэ курсыг үүсгэсэн хүн биш байна.'
        redirect_to :action => 'show', :id => @course
      end
      return false
    end
  end


end
