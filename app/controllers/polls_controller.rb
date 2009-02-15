class PollsController < ApplicationController
  before_filter :login_required,
                :except => [:answer]
  layout 'account'
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @poll_pages, @polls = paginate :polls, :per_page => 10
  end

  def show
    @poll = Poll.find(params[:id])
  end

  def new
    @poll = Poll.new
  end

  def create
    @poll = Poll.new(params[:poll])
    if @poll.save
      flash[:notice] = 'Poll was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @poll = Poll.find(params[:id])
  end

  def update
    @poll = Poll.find(params[:id])
    if @poll.update_attributes(params[:poll])
      flash[:notice] = 'Poll was successfully updated.'
      redirect_to :action => 'show', :id => @poll
    else
      render :action => 'edit'
    end
  end

  def answer
    @poll = Poll.find(params[:poll]['id'])
    if !params[:poll_choice].nil?
      @choice = PollChoice.find(params[:poll_choice]['id'])
      @choice.increment!('counter')
      session['polled'] = true
    end
    @total = PollChoice.sum(:counter, :conditions=>["poll_id = ?", @poll.id])
    render :partial=> 'polls/result', :layout =>false
  end

  def destroy
    Poll.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
