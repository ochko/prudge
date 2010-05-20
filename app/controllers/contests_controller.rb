class ContestsController < ApplicationController
  before_filter :require_user,
                :except => [:index, :last, :show, :participant]

  before_filter :require_judge, :only => [:create, :update, :destroy]
  before_filter :prepare_wmd, :only => [:edit, :new]

  def index
    @contests = Contest.find(:all, :order => "start DESC")
  end

  def last
    @contest = Contest.find(:last, :order => "start ASC")
    @numbers, @standings = @contest.standings
    render :action => 'show'
  end

  def show
    @contest = Contest.find(params[:id])
  end

  def participants
    @contest = Contest.find(params[:id])
    @numbers, @standings = @contest.standings
    render :partial => 'participants'
  end

  def new
    @contest = Contest.new
  end

  def create
    @contest = Contest.new(params[:contest])
    if @contest.save
      flash[:notice] = 'Тэмцээнийг үүсгэлээ.'
      redirect_to @contest
    else
      render :action => 'new'
    end
  end

  def edit
    @contest = Contest.find(params[:id])
  end

  def update
    @contest = Contest.find(params[:id])
    if @contest.update_attributes(params[:contest])
      flash[:notice] = 'Тэмцээнийг шинэчлэн хадгаллаа.'
      redirect_to @contest
    else
      render :action => 'edit'
    end
  end

  def destroy
    Contest.find(params[:id]).destroy
    redirect_to :action => 'index'
  end

  def participant
    @user = User.find(params[:user])
    contest = Contest.find(params[:contest])
    @solutions = contest.solutions.for_user(@user)
    render :partial=>'solved'
  end

end
