class HomeController < ApplicationController
  def about
    render :layout => 'static'
  end

  def dashboard
    authorize! :read, :dashboard
  end
end
