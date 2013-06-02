class ProblemObserver < ActiveRecord::Observer
  def after_save(problem)
    if problem.changes['contest_id'] && problem.user.email_valid?
      Notifier.problem_selection(problem.user, problem.contest, problem)
    end
  end

  def before_save(problem)
    problem.update_active_interval if problem.changes['contest_id']
  end
end
