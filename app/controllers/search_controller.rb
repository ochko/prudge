class SearchController < ApplicationController
  def index
    @results = ThinkingSphinx.search(params[:q], :per_page => 10,
                                     :page => params[:page])
    @results.delete_if { |r| !r.respond_to?('active?') || !r.active? }
  end

end
