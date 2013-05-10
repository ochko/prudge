class SearchController < ApplicationController
  def index
    @results = ThinkingSphinx.
      search(params[:q], :excerpts => {}).
      page(params[:page]).per(20)

    @results.context[:panes] << ThinkingSphinx::Panes::ExcerptsPane
  end

end
