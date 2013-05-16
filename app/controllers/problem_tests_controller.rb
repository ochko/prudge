# -*- coding: utf-8 -*-
class ProblemTestsController < ApplicationController
  load_resource :problem

  before_filter :load_test, :only => [:show, :input, :output, :destroy]

  def index
    @problem_test = @problem # for title
    @tests = @problem.tests
  end

  def show
    if cannot? :read, @problem
      flash_notce 'test.hidden'
      redirect_to @problem
    end
  end

  def input
    send_attachment :input
  end

  def output
    send_attachment :output
  end

  def new
    @problem_test = @problem.tests.build(hidden: true)
    if cannot? :update, @problem
      flash_notice 'test.frozen'
      redirect_to @problem
    end
  end

  def create
    @problem_test = @problem.tests.build(params[:problem_test])

    if can? :update, @problem
      if @problem_test.save
        flash_notice 'test.saved'
        redirect_to problem_tests_path(@problem)
      else
        render :action => 'new'
      end
    else
      flash_notice] = 'test.frozen'
    end
  end

  def destroy
    if can? :update, @problem
      @problem_test.destroy
      flash_notice 'test.deleted'
    else
      flash_notice 'test.nodelete'
    end
    redirect_to problem_tests_path(@problem)
  end

  private

  def load_test
    @problem_test = @problem.tests.find(params[:id])
  end

  def send_attachment(attribute)
    if can?(:update, @problem) || can?(:read, @problem_test)
      attachment = @problem_test.send(attribute)

      send_file(attachment.path,
                :filename => attachment.original_filename,
                :disposition => 'attachment')
    end
  end
end
