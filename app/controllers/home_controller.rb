class HomeController < ApplicationController

  def index
    welcome
    render :action => 'welcome'
  end

  def welcome
    behavior_cache Page, :tag => (params[:page] || 1) do
      @news = Page.
        paginate(:page => params[:page], :per_page => 5,
                 :conditions=>["category = ?", 'news'],
                 :order => "created_at desc")
    end
  end

  def aboutus
  end

  def help
    behavior_cache Page, :tag => (params[:page] || 1) do
      @helps = Page.
        paginate(:page => params[:page], :per_page => 5,
                 :conditions=>["category = ?", 'help'],
                 :order => "created_at desc")
    end
  end

  def rules
    behavior_cache Page, :tag => (params[:page] || 1) do
      @rules = Page.
        paginate(:page => params[:page], :per_page => 5,
                 :conditions=>["category = ?", 'rule'],
                 :order => "created_at asc")
    end
  end
end
