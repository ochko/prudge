class ParticipantsController < ApplicationController
  before_filter :require_user

  def index
    @contest = Contest.find(params[:id])
    @numbers, @standings = @contest.standings
    render :partial => 'participants'
  end

  def show
    @user = User.find(params[:user])
    contest = Contest.find(params[:contest])
    @solutions = contest.solutions.for_user(@user)
    render :partial=>'solved'
  end

end
