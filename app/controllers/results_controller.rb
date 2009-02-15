class ResultsController < ApplicationController
  before_filter :login_required

  access_control [:list,
                  :destroy] => 'Judge'
  layout 'problems'

  def list
    conditions = case params['field']
    when "solution" then ["r.solution_id = ?", "#{params[:query]}"]
    when "test" then ["r.test_id = ?", "#{params[:query]}"]
    when "user" then ["u.login LIKE ?", "%#{params[:query]}%"]
    when "prob" then ["p.name LIKE ?", "%#{params[:query]}%"]
    else ["1"]
    end

    @results = Result.
      find(:all,
           :from => "results r",
           :select => "r.*, u.login, p.name",
           :joins =>"join solutions s on r.solution_id = s.id " +
                    "join problems p on s.problem_id = p.id " +
                    "join users u on s.user_id = u.id",
           :order => "r.solution_id desc, r.id",
           :conditions => conditions,
           :limit => 40)
    if request.xml_http_request?
        render :partial => "search", :layout => false
    end
  end

  def show
    @result = Result.find(params[:id])
    restrict_to "Judge" do
      return
    end
    contest = @result.solution.problem.contest
    if @result.test.hidden
      flash[:notice] = 'Жинхэнэ тестийг харж болохгүй!.'
      redirect_to :controller=> 'contests', :action => 'show',
                  :id=>contest
      return
    elsif contest.end > Time.now() and
        @result.solution.user_id != current_user.id
      flash[:notice] = 'Тэмцээн явагдаж байна.'
      redirect_to :controller=> 'contests', :action => 'show', :id=>contest
      return
    end
  end

  def destroy
    Result.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
