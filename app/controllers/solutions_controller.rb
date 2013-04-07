# -*- coding: utf-8 -*-
class SolutionsController < ApplicationController
  menu :problem

  before_filter :require_user, :except=> [:submited, :solved, :best]

  def index
    @solutions = Solution.
      paginate(:include => [:user, :problem], :page => params[:page],
               :order => 'solutions.source_updated_at desc')
    respond_to do |format|
      format.js { render :layout => false }
      format.html
    end
  end

  def show
    seeing { render :action => :show }
  end

  def best
    @problem = Problem.find(params[:problem_id])
    @solution = @problem.solutions.best
    unless @solution
      render :text => '<table><tr><td>Энэ бодлогыг одоогоор нэг ч хүн бодоогүй байна</td></tr</table>'
    else
      render :partial => 'best'
    end
  end

  def submited
    @problem = Problem.find(params[:problem_id])
    @solutions = @problem.solutions(:include => [:language, :user],
                                    :order => 'source_updated_at DESC')
    if @solutions.empty?
      render :text => '<table><tr><td>Энэ бодлогыг одоогоор нэг ч хүн бодоогүй байна</td></tr</table>'
    else
      render :partial => 'list'
    end
  end

  def solved
    @problem = Problem.find(params[:problem_id])
    @solutions = @problem.solutions.correct(:include => [:language, :user],
                                            :order => 'source_updated_at DESC')
    if @solutions.empty?
      render :text => '<table><tr><td>Энэ бодлогыг одоогоор нэг ч хүн зөв бодоогүй байна</td></tr</table>'
    else
      render :partial => 'list'
    end
  end

  def view
    seeing { render :action => :view }
  end

  def download
    seeing do
      send_file(@solution.source.path,
                :filename => @solution.source_file_name,
                :disposition => 'attachment')
    end
  end

  def new
    @problem = Problem.find(params[:problem])
    @solution = current_user.last_submission_of(@problem)
    if @solution.nil? || (@solution.contest && @solution.contest.finished?)
      @solution = @problem.solutions.build
      @solution.contest = @problem.contest unless (@solution.contest && @problem.contest.finished?)
      return unless validate_solvable?
    else
      redirect_to @solution
    end
  end

  def create
    @solution = current_user.solutions.build(params[:solution])
    @solution.apply_contest
    return unless validate_solvable?
    @last_one = current_user.last_submission_of(@solution.problem)
    if @last_one
      if !@last_one.locked?
        if @last_one.freezed?
          @solution.save
          @last_one = @solution
        else
          @last_one.cleanup!
          @last_one.update_attributes(params[:solution])
        end
        @last_one.commit_to_repo
      else
        flash[:notice] = "Та хэн нэгний бодолтыг үзчихсэн учраас энэ бодлогыг дахин бодож болохгүй"
      end
      redirect_to @last_one
    else
      if @solution.save
        @solution.insert_to_repo
        flash[:notice] = 'Бодолтыг хадгалж авлаа.'
        redirect_to @solution
      else
        render :action => 'new'
      end
    end
  end

  def edit
    editing { render :action => 'edit' }
  end

  def update
    editing do 
      @solution.repost!
      if @solution.update_attributes(params[:solution])
        flash[:notice] = 'Бодолт шинэчлэгдлээ.'
        redirect_to @solution
      else
        render :action => 'edit'
      end
    end
  end

  def destroy
    editing do 
      @solution.destroy
      redirect_to @solution.problem
    end
  end

  def check
    @solution = Solution.find(params[:id])
    if !judge?
      if !current_user.owns?(@solution)
        render :text => 'Бусдын бодлогыг шалгахгүй!'
        return
      elsif @solution.judged?
        render :text => 'Шалгачихсан'
        return
      end
    end
    if @solution.problem.tests.real.empty?
      render :text => 'Шалгах тэст байхгүй байна(Эсвэл харагдахгүй тэст байхгүй)'
      return
    end
    @solution.submit
    render :partial => 'results/wait'
  end

  private

  def seeing
    @solution = Solution.find(params[:id])
    authorize! :read, @solution
    current_user.saw!(@solution)
    yield
  rescue CanCan::AccessDenied => exception
    flash[:notice] = exception.message
    redirect_to (@solution.contest.nil? || @solution.contest.finished?) : @solution.problem : @solution.contest
  end

  def editing
    @solution = Solution.find(params[:id])
    authorize! :modify, @solution
    Solution.transaction do
      yield
    end
  rescue CanCan::AccessDenied => exception
    flash[:notice] = exception.message
    redirect_to current_user.owns?(@solution) ? @solution : @solution.problem
  end

  def validate_solvable?
    return true unless contest = @solution.contest
    if current_user.owns?(@solution.problem) && !contest.finished?
      flash[:notice] = 'Уучлаарай, өөрийнхөө дэвшүүлсэн бодлогыг тэмцээн дууссаны дараа л бодож болно!.'
      redirect_to contest
      return false
    elsif !contest.started?
      flash[:notice] = 'Эхлээгүй тэмцээний бодлогыг бодож болохгүй!.'
      redirect_to contest
      return false
    elsif contest.finished?
      return true
    elsif !contest.open? && current_user.level > contest.level
      flash[:notice] = 'Таны түвшин энэ тэмцээнийхээс дээгүүр байна.'
      redirect_to contest
      return false
    elsif contest.private? && !contest.contributors.include?(current_user)
      flash[:notice] = 'Энэ тэмцээнд зөвхөн дэвшүүлсэн бодлого тань сонгогдсон тохиолдолд оролцоно. Та тэмцээн дууссаны дараа бодлогуудыг бодож болно.'
      redirect_to contest
      return false
    else
      return true
    end
  end
end
