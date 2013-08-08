# -*- coding: utf-8 -*-

class CommentsController < ApplicationController

  respond_to :js, only: [:create, :destroy, :show]
  respond_to :html, only: [:index]

  def show
    @comments = Comment.
      where(:topic_id => params[:id],
            :topic_type => params[:type].capitalize).
      order('created_at DESC').page(params[:page])
  end

  def index
    authorize! :destroy, Comment

    @comments = Comment.order('created_at DESC').
      page(params[:page]).per(50).preload(:user)

    respond_with @comments
  end

  def create
    # TODO: Check authorization
    @comment = Comment.new(params[:comment])
    if current_user.currently_commented?
      @comment.errors[:text] << message_for(:rate_limited)
    else
      @comment.user = current_user
      @comment.save
    end
    respond_with @comment, layout: false
  end

  def destroy
    # TODO: Check authorization
    comment = current_user.comments.find(params[:id])
    comment.destroy
    respond_with comment, layout: false
  end

end
