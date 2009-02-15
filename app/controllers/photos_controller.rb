class PhotosController < ApplicationController
  before_filter :login_required

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def new
    @photo = Photo.new
    @photo.user = User.find(params[:user_id])
  end

  def create
    for photo in Photo.
        find(:all,
             :conditions => ["user_id = ?",
                             current_user.id])
      photo.destroy
    end
    @photo = Photo.new(params[:photo])
    @photo.user_id = current_user.id
    if @photo.save
      User.update(@photo.user_id, { :updated_at => Time.now})
      flash[:notice] = 'Зургаа амжилттай орууллаа.'
      redirect_to :controller => 'account', :action => 'show',
                  :id => @photo.user_id
    else
      render :action => 'new'
    end
  end

  def destroy
    @photo = Photo.find(params[:id])
    if current_user.id == @photo.user_id
      @photo.destroy
    end
    redirect_to :controller => 'account', :action => 'show',
                :id => curent_user.id
  end
end
