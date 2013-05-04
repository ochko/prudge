class JudgeAbility < UserAbility
  def initialize(user)
    can :read, :dashboard

    can [:read, :update, :check, :approve], Problem

    can :destroy, Problem do |problem|
      problem.solutions.count == 0
    end

    can [:modify, :check], Solution

    super(user)
  end
end
