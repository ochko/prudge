# -*- coding: utf-8 -*-
class ResultsController < ApplicationController
  load_and_authorize_resource :result

  def show
    @solution = Solution.find(params[:solution_id])
    @result = @solution.results.find(params[:id])
  end

end
