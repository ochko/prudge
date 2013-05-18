class SearchController < ApplicationController
  def index
    @results = ThinkingSphinx.
      search(params[:q], :excerpts => {}).
      page(params[:page]).per(20)

    @results.context[:panes] << ThinkingSphinx::Panes::ExcerptsPane
  end

  def hints
    render :json => (Problem.uniq.pluck(:name) +
                     Post.uniq.pluck(:title) +
                     Contest.uniq.pluck(:name)).sort
  end
end
