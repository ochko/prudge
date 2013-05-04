class UserAbility < BaseAbility
  def initialize(user)
    super(user)

    can :read, Solution do |solution|
      user.owns?(solution) ||
        (!solution.competing? && user.solved?(solution.problem))
    end

    can :manage, Post, :author_id => user.id, :category => 'blog'
    
    can [:watch, :unwatch], Contest
    can :create, [Problem, Comment]
  end
end
