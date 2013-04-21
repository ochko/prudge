# -*- coding: utf-8 -*-
class CommentsController < ApplicationController
  before_filter :require_user, :except => [:index]
  before_filter :require_admin, :only => [:destroy, :moderate]

  menu :discussion

  def show
    @comments = Comment.
      where(:topic_id => params[:id],
            :topic_type => params[:type].capitalize).
      order('created_at DESC').page(params[:page])

    render :layout => false
  end
  
  def index
    @comments = Comment.order('created_at DESC').
      page(params[:page]).preload(:user)

    respond_to do |format|
      format.html
      format.rss
      format.js { render :layout => false }
    end
  end

  def moderate
    @comments = Comment.order('created_at DESC').
      page(params[:page]).per(50).preload(:user)
  end

  def create
    @comment = current_user.comments.build(params[:comment])
    if current_user.currently_commented?
      @comment.errors[:text] << 'Хэт хурдан байна, 10 Секунд хүлээгээд дахин илгээнэ үү?'
    else
      @comment.save
    end
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    if !@comment.nil?
      @comment.destroy
      respond_to do |format|
        format.js
      end
    end
  end

end
