class RoleUsersController < ApplicationController
  before_filter :login_required
  access_control :DEFAULT => 'Admin'

  layout 'account'

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
  :redirect_to => { :action => :list }

  def list
    @role_user_pages, @role_users = paginate :role_users, :per_page => 100
  end

  def show
    @role_user = RoleUser.find(params[:id])
  end

  def new
    @role_user = RoleUser.new
    @roles = Role.find(:all)
    @users = User.find(:all, :order => 'login')
  end

  def create
    @role_user = RoleUser.new(params[:role_user])
    if @role_user.save
      flash[:notice] = 'Оноолт хийгдсэн.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @role_user = RoleUser.find(params[:id])
    @roles = Role.find(:all)
    @users = User.find(:all)
  end

  def update
    @role_user = RoleUser.find(params[:id])
    if @role_user.update_attributes(params[:role_user])
      flash[:notice] = 'Оноолтыг шинэчилсэн.'
      redirect_to :action => 'show', :id => @role_user
    else
      render :action => 'edit'
    end
  end

  def destroy
    RoleUser.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
