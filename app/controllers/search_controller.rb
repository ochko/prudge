class SearchController < ApplicationController
  def index
    @results = ThinkingSphinx.
      search(params[:q]).
      page(params[:page]).per(20)

    @results.delete_if { |r| !r.respond_to?('active?') || !r.active? }
  end

end
