class Page < ActiveRecord::Base
  def self.category(name, params)
    where(:category => name).order("created_at desc").page(params[:page]).per(5)
  end

  def name
    title
  end

  def text
    content
  end
end
