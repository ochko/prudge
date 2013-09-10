class SearchController < ApplicationController
  def index
    @results = ThinkingSphinx.
      search(params[:q], :excerpts => {}).
      page(params[:page]).per(20)

    @results.context[:panes] << ThinkingSphinx::Panes::ExcerptsPane

    flash_notice(:search_result_empty) if @results.empty?

  rescue ThinkingSphinx::SyntaxError
    @results = nil
    flash_error(:search_syntax_error, query: params[:q])
  end

  def hints
    render :json => (Problem.uniq.pluck(:name) +
                     Post.uniq.pluck(:title) +
                     Contest.uniq.pluck(:name)).sort
  end
end
