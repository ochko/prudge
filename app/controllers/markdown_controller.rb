class MarkdownController < ApplicationController
  def create
    render :text => MarkdownRenderer.render(params[:text])
  end
end
