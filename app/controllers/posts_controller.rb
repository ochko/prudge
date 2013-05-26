class PostsController < ApplicationController
  load_and_authorize_resource :except => [:blog, :help]

  def index
    @user = User.find(params[:user_id])
    @posts = @user.posts.order('created_at desc')
    render :partial => 'index'
  end

  def blog
    load_category('blog')
  end

  def help
    load_category('help')
  end

  def show
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(params[:post])
    @post.author = current_user
    @post.category = 'blog' unless current_user.admin?

    if @post.save
      flash[:notice] = 'Post was successfully created.'
      redirect_to @post
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @post.update_attributes(params[:post])
      flash[:notice] = 'Post was successfully updated.'
      redirect_to @post
    else
      render :action => 'edit'
    end
  end

  def destroy
    @post.destroy
    redirect_to :action => 'index'
  end

  private

  def load_category(category)
    @posts = Post.
      where(category: category).
      order("created_at desc").
      page(params[:page]).
      preload(:author)
  end
end
