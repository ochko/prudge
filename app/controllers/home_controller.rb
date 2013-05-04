class HomeController < ApplicationController
  def dashboard
    authorize! :read, :dashboard
    render :layout => 'application'
  end

  def about
  end

  def index
    @news = Page.category('news', params)
  end

  def help
    @helps = Page.category('help', params)
  end

  def rules
    @rules = Page.category('rule', params)
  end

  def international
  end

  def asian
  end
end
