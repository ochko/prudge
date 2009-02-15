class QaController < ApplicationController
  layout 'home'
  before_filter :login_required,
                :except => [:index, :show]

  access_control [:edit,
                  :list,
                  :destroy,
                  :update] => 'Admin'
  def index
    behavior_cache QuestionAnswer do
      @question_answers = QuestionAnswer.all
    end
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @question_answers = QuestionAnswer.all
  end

  def show
    @question_answer = QuestionAnswer.find(params[:id])
  end

  def new
    @question_answer = QuestionAnswer.new
  end

  def create
    @question_answer = QuestionAnswer.new(params[:question_answer])
    @question_answer.asker_id = current_user.id
    if @question_answer.save
      flash[:notice] = 'QuestionAnswer was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @question_answer = QuestionAnswer.find(params[:id])
  end

  def update
    @question_answer = QuestionAnswer.find(params[:id])
    @question_answer.update_attribute('answerer_id',current_user.id)
    if @question_answer.update_attributes(params[:question_answer])
      flash[:notice] = 'QuestionAnswer was successfully updated.'
      redirect_to :action => 'show', :id => @question_answer
    else
      render :action => 'edit'
    end
  end

  def destroy
    QuestionAnswer.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
