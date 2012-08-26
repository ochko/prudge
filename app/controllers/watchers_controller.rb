class WatchersController < ApplicationController
  before_filter :require_user

  def watch
    contest = Contest.find params[:id]
    contest.watchers << current_user
    render :nothing => true
  end

  def unwatch
    contest = Contest.find params[:id]
    contest.watchers.delete current_user
    render :nothing => true
  end
end
