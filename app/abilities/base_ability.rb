class BaseAbility
  include CanCan::Ability

  def initialize(user)
    can :read, [Post, Comment]
    can [:read, :last], Contest

    can :read, Problem, ["active_from < ?", Time.now] do |problem|
      problem.publicized?
    end
  end
end
