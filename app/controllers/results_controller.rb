# -*- coding: utf-8 -*-
class ResultsController < ApplicationController
  before_filter :require_user
  menu :problem

  def show
    @result = ActiveRecord::Base::Result.find(params[:id])

    return if judge?
    
    if !current_user.owns?(@result.solution)
      flash[:notice] = 'Бусдын тэстийг харж болохгүй'
      redirect_to @result.solution.problem
    elsif @result.hidden
      flash[:notice] = 'Жинхэнэ тэстийг харж болохгүй!.'
      redirect_to @result.solution
    end
  end

end
