class SolutionObserver < ActiveRecord::Observer
  def after_destroy(solution)
    solution.user.resum_points!
    solution.problem.resum_counts!
  end

  def after_save(solution)
    changes = solution.changes

    solution.problem.resum_counts! if changes["state"]

    if changes["point"]
      solution.user.resum_points!
      solution.contest.rank!
    end
  end

  def after_update(solution)
    if solution.changes['source_fingerprint']
      solution.reset!
      solution.log("Updated solution for #{solution.problem_id}")
    end
  end

  def after_create(solution)
    solution.log("New solution for #{solution.problem_id}")
  end

  def before_create(solution)
    solution.reset!
  end
end
