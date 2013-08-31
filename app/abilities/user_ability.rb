class UserAbility < BaseAbility
  def initialize(user)
    super(user)

    can :read, Result do |result|
      !result.hidden || user.owns?(result.solution)
    end

    can :read, Solution do |solution|
      user.owns?(solution) ||
        (!solution.competing? && user.solved?(solution.problem))
    end

    can :manage, Post, :author_id => user.id, :category => 'blog'

    can [:watch, :unwatch], Contest

    can :create, [Problem, Comment]

    can :read, Problem, :user_id => user.id

    cannot :destroy, Problem do |problem|
      problem.solutions.exists?
    end
  end
end
