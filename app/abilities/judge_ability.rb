class JudgeAbility < UserAbility
  def initialize(user)
    can :read, :dashboard

    can :manage, Contest

    can [:manage, :check, :approve], Problem

    can :manage, ProblemTest

    can [:update, :check], Solution

    can :create, Solution do |solution|
      contest = solution.contest
      (contest.nil? || contest.continuing?) && solution.fresh?
    end

    can :read, Result

    super(user)
  end
end
