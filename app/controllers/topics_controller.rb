# -*- coding: utf-8 -*-
class TopicsController < ApplicationController
  before_filter :require_admin, :except => [:index, :show]
  before_filter :prepare_wmd, :only => [:edit, :new]

  layout 'discussions'

  def index
    if !params[:type]
      @topics = Topic.paginate(:page=> params[:page], :per_page => 20,
                               :order => 'commented_at DESC')
    elsif %w[contest lesson topic].include? params[:type]
      @topics = params[:type].capitalize.constantize.commented.
        paginate(:page=> params[:page], :order => 'commented_at DESC')
    elsif 'problem' == params[:type] || 'problems' == params[:type]
      @topics = Problem.commented.active.
        paginate(:page=> params[:page], :order => 'commented_at DESC')
    end
  end

  def show
    if !params[:type]
      @topic = Topic.
        find(params[:id])
    elsif %w[contest problem lesson topic solution].include? params[:type].singularize
      @topic = params[:type].singularize.capitalize.constantize.find(params[:id])
      if @topic.instance_of?(Problem) && !@topic.available_to(current_user)
        flash[:notice] = "Уучлаарай, Энэ бодлогыг одоохондоо үзэх боломжгүй"
        redirect_to '/topic/problem'
      end
    end
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(params[:topic])
    if @topic.save
      flash[:notice] = 'Хэлэлцүүлгийн сэдвийг үүсгэлээ'
      redirect_to @topic
    else
      render :action => 'new'
    end
  end

  def edit
    @topic = Topic.find(params[:id])
  end

  def update
    @topic = Topic.find(params[:id])
    if @topic.update_attributes(params[:topic])
      flash[:notice] = 'Хэлэлцүүлгийн сэдвийг хадгалчихлаа'
      redirect_to @topic
    else
      render :action => 'edit'
    end
  end

  def destroy
    Topic.find(params[:id]).destroy
    flash[:notice] = 'Хэлэлцүүлгийн сэдвийг устгав'
    redirect_to :action => :index
  end
end
