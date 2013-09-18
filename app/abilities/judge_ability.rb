class JudgeAbility < UserAbility
  def initialize(user)
    can :read, :dashboard

    can :manage, Contest

    can [:manage, :check, :approve], Problem

    can :manage, ProblemTest

    can [:update, :check], Solution

    can :create, Solution do |solution|
      if contest = solution.contest
        contest.continuing? && solution.fresh?
      else
        solution.fresh?
      end
    end

    can :read, Result

    super(user)
  end
end
