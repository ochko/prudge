class ProblemObserver < ActiveRecord::Observer
  def after_save(problem)
    if problem.changes['contest_id']
      problem.user.deliver_problem_selection!(problem)
    end
  end

  def before_save(problem)
    problem.update_active_interval if problem.changes['contest_id']
  end
end
