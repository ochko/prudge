class PollChoicesController < ApplicationController
  before_filter :login_required
  layout 'account'
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @poll_choice_pages, @poll_choices = paginate :poll_choices, :per_page => 10
  end

  def show
    @poll_choice = PollChoice.find(params[:id])
  end

  def new
    @poll_choice = PollChoice.new
  end

  def create
    @poll_choice = PollChoice.new(params[:poll_choice])
    if @poll_choice.save
      flash[:notice] = 'PollChoice was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @poll_choice = PollChoice.find(params[:id])
  end

  def update
    @poll_choice = PollChoice.find(params[:id])
    if @poll_choice.update_attributes(params[:poll_choice])
      flash[:notice] = 'PollChoice was successfully updated.'
      redirect_to :action => 'show', :id => @poll_choice
    else
      render :action => 'edit'
    end
  end

  def destroy
    PollChoice.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
