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
end
