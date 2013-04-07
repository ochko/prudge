class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :update, :create, :destroy, :to => :touch
    alias_action :update, :destroy, :to => :modify

    user ||= User.new # guest user (not logged in)
    if user.admin?
      can :manage, :all
    elsif user.judge?
      can :read, [Comment, Language, Page, Topic]
      can :modify Solution
    else
      can :read, Problem {|problem| user.owns?(problem) || problem.public? }
      can :read, [Contest, Lesson, Topic, Comment, Language, Page]

      can :check, Solution, :user_id => user.id, :state => 'updated'
      can :read, Solution do |solution|
        user.owns?(solution) ||
          (!solution.competing? && user.solved?(solution.problem))
      end
      can :modify, Solution do |solution|
        user.judge? || (user.owns?(@solution) && @solution.open?)
      end
    end
  end
end
