class CoderAbility < UserAbility
  def initialize(user)
    can :read, Contest

    can :read, Problem do |problem|
      problem.publicized? || user.owns?(problem)
    end

    can :read, ProblemTest do |test|
      (test.problem.publicized? && test.visible?) || user.owns?(test.problem)
    end

    can [:update, :destroy], Problem do |problem|
      user.owns?(problem) && !problem.publicized?
    end

    can [:create, :update, :destroy], ProblemTest do |test|
      user.owns?(test.problem) && !test.problem.publicized?
    end

    can :check, Solution do |solution|
      user.owns?(solution) && solution.updated?
    end

    can [:update, :destroy], Solution do |solution|
      user.owns?(solution) && solution.open?
    end

    can :create, Solution do |solution|
      if contest = solution.contest
        contest.continuing? && solution.fresh?
      else
        user.owns?(solution.problem) && solution.fresh?
      end
    end

    cannot :destroy, Problem do |problem|
      problem.publicized?
    end

    super(user)
  end
end
