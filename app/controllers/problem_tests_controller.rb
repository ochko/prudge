class ProblemTestsController < ApplicationController
  before_filter :require_user

  def show
    @problem_test = ProblemTest.find(params[:id])
    if !is_viewable(@problem_test)
      flash[:notice] = 'Тэстийг үзэж болохгүй.'
      redirect_to @problem_test.problem
    end
  end

  def new
    @problem = Problem.find(params[:problem_id])
    @problem_test = @problem.tests.build
    unless is_touchable(@problem_test)
      flash[:notice] = 'Тэст оруулж болохгүй.'
      redirect_to @problem
    end
  end

  def create
    @problem_test = ProblemTest.new(params[:problem_test])
    if is_touchable(@problem_test)
      if @problem_test.save
        if request.xml_http_request?
          render :partial => 'test', :object => @problem_test
        else
          flash[:notice] = 'Тэстийг хадгалж авлаа.'
          redirect_to @problem_test.problem
        end
      else
        render :action => 'new'
      end
    else
      flash[:notice] = 'Тэст оруулж болохгүй.'
      redirect_to @problem_test.problem
    end
  end

  def edit
    @problem_test = ProblemTest.find(params[:id])
    if !is_touchable(@problem_test)
      flash[:notice] = 'Тэстийг засварлаж болохгүй.'
      redirect_to @problem_test.problem
      return
    end
  end

  def update
    @problem_test = ProblemTest.find(params[:id])
    if is_touchable(@problem_test)
      if @problem_test.update_attributes(params[:problem_test])
        flash[:notice] = 'ProblemTest was successfully updated.'
        redirect_to @problem_test
      else
        render :action => 'edit'
      end
    else
      flash[:notice] = 'Тэстийг засварлаж болохгүй.'
      redirect_to @problem_test.problem
      return
    end
  end

  def destroy
    @problem_test = ProblemTest.find(params[:id])
    if is_touchable(@problem_test)
      @problem_test.destroy
    else
      flash[:notice] = 'Тэстийг устгаж болохгүй.'
    end
    respond_to do |format|
      format.html { redirect_to @problem_test.problem }
      format.js
    end
    
  end

  protected
  def is_touchable(test)
    return true if current_user.judge?
    return true if test.problem.owned_by?(current_user)
    return false
  end

  def is_viewable(test)
    return true if test.problem.owned_by?(current_user)
    return true if current_user.judge?
    return false
  end

end
