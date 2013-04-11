class Page < ActiveRecord::Base
  def self.category(name, params)
    paginate(:page => params[:page], :per_page => 5,
             :conditions=>["category = ?", name],
             :order => "created_at desc")
  end

  def name
    title
  end

  def text
    content
  end
end
