# -*- coding: utf-8 -*-
class TopicsController < ApplicationController
  menu :discussion

  load_and_authorize_resource :except => [:index, :show]
  authorize_resource :only => :show

  def index
    klass = contantize
    @topics = klass.commented.
      paginate(:page=> params[:page], :order => 'commented_at DESC')
  end

  def show
    klass = contantize %w(contest problem lesson topic solution)
    @topic = klass.find(params[:id])
  end

  def new
  end

  def create
    if @topic.save
      flash[:notice] = 'Хэлэлцүүлгийн сэдвийг үүсгэлээ'
      redirect_to @topic
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @topic.update_attributes(params[:topic])
      flash[:notice] = 'Хэлэлцүүлгийн сэдвийг хадгалчихлаа'
      redirect_to @topic
    else
      render :action => 'edit'
    end
  end

  def destroy
    @topic.destroy
    flash[:notice] = 'Хэлэлцүүлгийн сэдвийг устгав'
    redirect_to :action => :index
  end

  private

  def contantize allowed=%w(contest problem lesson topic)
    type = (params[:type] || 'topic').singularize
    klass = allowed.include?(type) ? type.capitalize.constantize : Topic
  end
end
