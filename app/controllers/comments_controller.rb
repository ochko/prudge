# -*- coding: utf-8 -*-
class CommentsController < ApplicationController
  def show
    @comments = Comment.
      where(:topic_id => params[:id],
            :topic_type => params[:type].capitalize).
      order('created_at DESC').page(params[:page])

    render :layout => false
  end
  
  def index
    authorize! :destroy, Comment

    @comments = Comment.order('created_at DESC').
      page(params[:page]).per(50).preload(:user)
  end

  def create
    @comment = current_user.comments.build(params[:comment])
    if current_user.currently_commented?
      @comment.errors[:text] << message_for(:rate_limited)
    else
      @comment.save
    end
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def destroy
    if @comment = Comment.find(params[:id])
      @comment.destroy
    end
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

end
