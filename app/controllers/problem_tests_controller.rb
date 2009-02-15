class ProblemTestsController < ApplicationController
  before_filter :login_required

  def show
    @problem_test = ProblemTest.find(params[:id])
    if !is_viewable(@problem_test)
      flash[:notice] = 'Тэстийг үзэж болохгүй.'
      redirect_to :controller=>'problems' ,:action => 'show',
      :id=>@problem_test.problem.id
    end
  end

  def new
    @problem_test = ProblemTest.new
    @problem_test.problem_id = params[:problem_id]
    if is_touchable(@problem_test)
      @problem_tests = @problem_test.problem.problem_tests
    else
      flash[:notice] = 'Тэст оруулж болохгүй.'
      redirect_to :controller=>'problems' ,:action => 'show',
      :id=>@problem_test.problem.id
    end
  end

  def create
    @problem_test = ProblemTest.new(params[:problem_test])
    if is_touchable(@problem_test)
      if @problem_test.save
        flash[:notice] = 'ProblemTest was successfully created.'
        if request.xml_http_request?
          @problem_tests = @problem_test.problem.problem_tests
          render :partial => 'list'
        else
          redirect_to :controller=>'problems',
                      :action => 'show', :id=>@problem_test.problem_id
        end
      else
        render :action => 'new'
      end
    else
      flash[:notice] = 'Тэст оруулж болохгүй.'
      redirect_to :controller=>'problems' ,:action => 'show',
      :id=>@problem_test.problem.id
    end
  end

  def edit
    @problem_test = ProblemTest.find(params[:id])
    if !is_touchable(@problem_test)
      flash[:notice] = 'Тэстийг засварлаж болохгүй.'
      redirect_to :controller=>'problems' ,:action => 'show',
                  :id=>@problem_test.problem.id
      return
    end
  end

  def update
    @problem_test = ProblemTest.find(params[:id])
    if is_touchable(@problem_test)
      if @problem_test.update_attributes(params[:problem_test])
        flash[:notice] = 'ProblemTest was successfully updated.'
        redirect_to :action => 'show', :id => @problem_test
      else
        render :action => 'edit'
      end
    else
      flash[:notice] = 'Тэстийг засварлаж болохгүй.'
      redirect_to :controller=>'problems' ,:action => 'show',
      :id=>@problem_test.problem.id
      return
    end
  end

  def destroy
    @problem_test = ProblemTest.find(params[:id]).destroy
    if is_touchable(@problem_test)
      @problem_test.destroy
    else
      flash[:notice] = 'Тэстийг устгаж болохгүй.'
    end
    redirect_to :action => 'new',
                :problem_id=>@problem_test.problem.id
  end

  protected
  def is_touchable(test)
    restrict_to "Judge" do
      return true
    end

    if test.problem.user_id == current_user.id
      return true
    end

    return false
  end

  def is_viewable(test)
    if test.problem.user_id == current_user.id
      return true
    end

    restrict_to "Judge" do
      return true
    end

    return false
  end

end
