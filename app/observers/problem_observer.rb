class ProblemObserver < ActiveRecord::Observer
  def after_save(problem)
    if problem.changes['contest_id'] && problem.contest && problem.user.email_valid?
      Notifier.problem_selection(problem.user, problem.contest, problem)
    end
    # point depends on tried_count and solved_count
    if problem.changes['tried_count'] || problem.changes['solved_count']
      problem.solutions.each do |solution|
        if solution.contest.nil? || solution.contest.continuing?
          solution.point = points_taken
          solution.save!
        end
      end

      problem.contest.rank! if problem.contest
    end
  end

  def before_save(problem)
    problem.update_active_interval if problem.changes['contest_id']
  end

  def after_create(problem)
    Stats.refresh('problems')
  end
end
