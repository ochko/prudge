class HomeController < ApplicationController
  def about
  end

  def dashboard
    authorize! :read, :dashboard
    render :layout => 'application'
  end
end
