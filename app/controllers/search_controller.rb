class SearchController < ApplicationController
  def index
    @results = ThinkingSphinx.
      search(params[:q], :excerpts => {}).
      page(params[:page]).per(20)

    @results.context[:panes] << ThinkingSphinx::Panes::ExcerptsPane

    flash_notice(:search_result_empty) if @results.empty?
  end

  def hints
    render :json => (Problem.uniq.pluck(:name) +
                     Post.uniq.pluck(:title) +
                     Contest.uniq.pluck(:name)).sort
  end
end
