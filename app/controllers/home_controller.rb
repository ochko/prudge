class HomeController < ApplicationController
  menu :home

  def index
    @news = Page.
      paginate(:page => params[:page], :per_page => 5,
               :conditions=>["category = ?", 'news'],
               :order => "created_at desc")
  end

  def about
  end

  def help
      @helps = Page.
        paginate(:page => params[:page], :per_page => 5,
                 :conditions=>["category = ?", 'help'],
                 :order => "created_at desc")
  end

  def rules
      @rules = Page.
        paginate(:page => params[:page], :per_page => 5,
                 :conditions=>["category = ?", 'rule'],
                 :order => "created_at asc")

  end
  def international
  end
  def asian
  end

end
