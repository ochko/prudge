# -*- coding: utf-8 -*-
class SolutionsController < ApplicationController
  menu :problem

  before_filter :require_user, :except=> [:submited, :solved, :best]

  def index
    @solutions = Solution.
      paginate(:include => [:user, :problem], :page => params[:page],
               :order => 'solutions.uploaded_at desc')
    respond_to do |format|
      format.js { render :layout => false }
      format.html
    end
  end

  def show
    @solution = Solution.find(params[:id])
    validate_showable?
  end

  def best
    @problem = Problem.find(params[:problem_id])
    @solution = @problem.best_solution
    unless @solution
      render :text => '<table><tr><td>Энэ бодлогыг одоогоор нэг ч хүн бодоогүй байна</td></tr</table>'
    else
      render :partial => 'best'
    end
  end

  def submited
    @problem = Problem.find(params[:problem_id])
    @solutions = @problem.solutions(:include => [:language, :user],
                                    :order => 'uploaded_at DESC')
    if @solutions.empty?
      render :text => '<table><tr><td>Энэ бодлогыг одоогоор нэг ч хүн бодоогүй байна</td></tr</table>'
    else
      render :partial => 'list'
    end
  end

  def solved
    @problem = Problem.find(params[:problem_id])
    @solutions = @problem.solutions.correct(:include => [:language, :user],
                                            :order => 'uploaded_at DESC')
    if @solutions.empty?
      render :text => '<table><tr><td>Энэ бодлогыг одоогоор нэг ч хүн зөв бодоогүй байна</td></tr</table>'
    else
      render :partial => 'list'
    end
  end

  def view
    @solution = Solution.find(params[:id])
    return if @solution.owned_by?(current_user)
    return unless validate_showable?
    solutions = current_user.solved(@solution.problem)
    if solutions.empty?
      flash[:notice] = "Бодлогыг өөрөө бодож чадсаны дараа л бусдын бодолтыг үзэх боломжтой"
      redirect_to @solution.problem
    else
      solutions.each { |solved| solved.lock! }
    end
  end

  def download
    @solution = Solution.find(params[:id])
    if @solution.owned_by? current_user
      send_file(@solution.source.path, 
                :filename => @solution.source_file_name, 
                :disposition => 'attachment')
      return
    end
    return unless validate_showable?
    solutions = current_user.solved(@solution.problem)
    if solutions.empty?
      flash[:notice] = "Бодлогыг өөрөө бодож чадсаны дараа л бусдын бодолтыг үзэх боломжтой"
      redirect_to @solution.problem
    else
      solutions.each { |solved| solved.lock! }
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
    params[:solution].merge!(:uploaded_at => Time.now)
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
    @solution = Solution.find(params[:id])
    return unless validate_touchable?
  end

  def update
    @solution = Solution.find(params[:id])
    return unless validate_touchable?
    @solution.cleanup!
    params[:solution].merge!(:uploaded_at => Time.now)
    if @solution.update_attributes(params[:solution])
      flash[:notice] = 'Бодолт шинэчлэгдлээ.'
      @solution.user.solution_uploaded!
      @solution.commit_to_repo
      redirect_to @solution
    else
      render :action => 'edit'
    end
  end

  def destroy
    @solution = Solution.find(params[:id])
    return unless validate_touchable?
    @solution.destroy
    redirect_to @solution.problem
  end

  def check
    @solution = Solution.find(params[:id])
    if !judge?
      if !@solution.owned_by?(current_user)
        render :text => 'Бусдын бодлогыг шалгахгүй!'
        return
      elsif @solution.nocompile || @solution.checked
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

  def validate_solvable?
    return true unless contest = @solution.contest
    if @solution.problem.owned_by?(current_user) && !contest.finished?
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

  def validate_showable?
    if !@solution.contest || @solution.contest.finished? || @solution.owned_by?(current_user)
      return true
    else
      flash[:notice] = 'Тэмцээн дуусаагүй байхад бусдын бодолтыг харахгүй!'
      redirect_to @solution.contest
      return false
    end
  end

  def validate_touchable?
    return true if judge?
    if !@solution.owned_by?(current_user)
      flash[:notice] ='Бусдын бодолтыг өөрчилж болохгүй!'
      redirect_to @solution.problem
      return false
    elsif @solution.locked?
      flash[:notice] ='Энэ бодолтыг өөрчилж болохгүй'
      redirect_to @solution
      return false
    elsif @solution.freezed?
      flash[:notice] ='Тэмцээн дууссан хойно бодолтыг өөрчилж болохгүй!'
      redirect_to @solution
      return false
    end
    true
  end

end
