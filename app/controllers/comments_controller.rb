class CommentsController < ApplicationController
  before_filter :require_user, :except => [:index]
  before_filter :require_admin, :only => [:destroy, :moderate]

  layout 'discussions'

  def show
    @comments = Comment.
      paginate(:page => params[:page], :order => 'created_at DESC',
               :conditions => ['topic_id = ? AND topic_type = ?',
                               params[:id], params[:type].capitalize])
  end
  
  def index
    @comments = Comment.
      paginate(:page => params[:page],
               :order => 'created_at DESC',
               :include => [:user])
    respond_to do |format|
      format.html
      format.rss
      format.js
    end
  end

  def moderate
    @comments = Comment.
      paginate(:page => params[:page], :per_page=> 50,
               :order => 'created_at desc',
               :include => [:user])
  end

  def create
    if current_user.currently_commented?
      render :text => 'Хэт хурдан байна, 10 Секунд хүлээгээд дахин илгээнэ үү?', :status => 404
      return
    end
    @comment = current_user.comments.build(params[:comment])
    if @comment.save
      render :partial => 'comments/comment', :object => @comment
    else
      render :text => @comment.errors.full_messages, :status => 404
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
