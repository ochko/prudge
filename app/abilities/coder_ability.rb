class CoderAbility < UserAbility
  def initialize(user)
    can :manage, Contest

    can :read, Problem, ["user_id = ?", user.id] do |problem|
      problem.publicized? || user.owns?(problem)
    end

    can :update, Problem do |problem|
      user.owns?(problem) && !problem.publicized?
    end

    can :check, Solution, :user_id => user.id, :state => 'updated'

    can :update, :destroy, Solution do |solution|
      user.owns?(solution) && solution.open?
    end

    can :create, Solution do |solution|
      contest = solution.contest
      (contest.nil? || contest.openfor?(user)) && solution.fresh?
    end

    super(user)
  end
end
