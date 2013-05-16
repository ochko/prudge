# -*- coding: utf-8 -*-
class ProblemTestsController < ApplicationController
  before_filter :require_user
  load_resource :problem
  before_filter :load_test, :only => [:show, :input, :output, :destroy]

  def index
    @problem_test = @problem # for title
    @tests = @problem.tests
  end

  def show
    if !is_viewable(@problem_test)
      flash[:notice] = 'Тэстийг үзэж болохгүй.'
      redirect_to @problem_test.problem
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
    unless is_touchable(@problem_test)
      flash[:notice] = 'Тэст оруулж болохгүй.'
      redirect_to @problem
    end
  end

  def create
    @problem_test = @problem.tests.build(params[:problem_test])

    if is_touchable(@problem_test)
      if @problem_test.save
        flash[:notice] = 'Тэстийг хадгалж авлаа.'
        redirect_to problem_tests_path(@problem)
      else
        render :action => 'new'
      end
    else
      flash[:notice] = 'Тэст оруулж болохгүй.'
      redirect_to problem_tests_path(@problem)
    end
  end

  def destroy
    if is_touchable(@problem_test)
      @problem_test.destroy
      flash[:notice] = 'Тэстийг устгав.'
    else
      flash[:notice] = 'Тэстийг устгаж болохгүй.'
    end

    redirect_to problem_tests_path(@problem)
  end

  private

  def load_test
    @problem_test = @problem.tests.find(params[:id])
  end

  def is_touchable(test)
    return true if current_user.judge?
    return true if current_user.owns?(test.problem)
    return false
  end

  def is_viewable(test)
    return true if current_user.owns?(test.problem)
    return true if current_user.judge?
    return false
  end

  def send_attachment(attribute)
    attachment = @problem_test.send(attribute)

    send_file(attachment.path,
              :filename => attachment.original_filename,
              :disposition => 'attachment')
  end
end
