class ResultsController < ApplicationController
  before_filter :require_user
  layout 'problems'

  def show
    @result = ActiveRecord::Result.find(params[:id])

    return if judge?
    
    contest = @result.solution.contest
    if !@result.solution.owned_by?(current_user)
      flash[:notice] = 'Бусдын тэстийг харж болохгүй'
      redirect_to contest
    elsif @result.hidden
      flash[:notice] = 'Жинхэнэ тэстийг харж болохгүй!.'
      redirect_to @result.solution
    end
  end

end
