class SearchController < ApplicationController
  def index
    @results = ThinkingSphinx.search(params[:q], :per_page => 10,
                                     :page => params[:page])
  end

end
