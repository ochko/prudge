class ProblemTypesController < ApplicationController
  before_filter :login_required,
                :except => [:index, :show]

  access_control [:new, :create, :edit, :update, :destroy] => 'Admin'

  layout 'problems'
  # GET /problem_types
  # GET /problem_types.xml
  def index
    @problem_types = ProblemType.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @problem_types }
    end
  end

  # GET /problem_types/1
  # GET /problem_types/1.xml
  def show
    @problem_type = ProblemType.find(params[:id])
    @problems = Problem.
      find(:all,
           :from => "problems p",
           :select => "p.*, u.login as login, count(s.id) as solution_count, "+
           "sum(s.correct) as correct_count",
           :joins => "join contests c on c.id = p.contest_id " +
           "left join users u on p.user_id = u.id " +
           "left join solutions s on p.id = s.problem_id ",
           :order => "contest_id, created_at",
           :conditions => ['c.start < NOW() and p.problem_type_id = ? ', @problem_type.id],
           :group => "p.id")

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @problem_type }
    end
  end

  # GET /problem_types/new
  # GET /problem_types/new.xml
  def new
    @problem_type = ProblemType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @problem_type }
    end
  end

  # GET /problem_types/1/edit
  def edit
    @problem_type = ProblemType.find(params[:id])
  end

  # POST /problem_types
  # POST /problem_types.xml
  def create
    @problem_type = ProblemType.new(params[:problem_type])

    respond_to do |format|
      if @problem_type.save
        flash[:notice] = 'ProblemType was successfully created.'
        format.html { redirect_to(@problem_type) }
        format.xml  { render :xml => @problem_type, :status => :created, :location => @problem_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @problem_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /problem_types/1
  # PUT /problem_types/1.xml
  def update
    @problem_type = ProblemType.find(params[:id])

    respond_to do |format|
      if @problem_type.update_attributes(params[:problem_type])
        flash[:notice] = 'ProblemType was successfully updated.'
        format.html { redirect_to(@problem_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @problem_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /problem_types/1
  # DELETE /problem_types/1.xml
  def destroy
    @problem_type = ProblemType.find(params[:id])
    @problem_type.destroy

    respond_to do |format|
      format.html { redirect_to(problem_types_url) }
      format.xml  { head :ok }
    end
  end
end
