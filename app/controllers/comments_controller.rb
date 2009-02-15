class CommentsController < ApplicationController
  before_filter :login_required
  access_control [:destroy] => 'Admin'

  def form
    @comment = Comment.new(params[:comment])
    @comments = Comment.
      find(:all,
           :conditions=>["topic_id = ? AND topic_type =?",
                         @comment.topic_id,
                         @comment.topic_type],
           :order=>'created_at')
    @box_title = "#{@comments.size} #{params[:commit]}"

    if request.xml_http_request?
      render :partial=>'form_list'
    else
      redirect_to :controller=>'home', :action=>'welcome'
    end
  end

  def create
    @comment = Comment.new(params[:comment])
    @comment.user_id = current_user.id
    if @comment.save
      render :partial => 'comments/list_item',
             :locals => { :comment => @comment}
    else
      render :text => 'Бичлэгийг хадгалж чадсангүй!'
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
