class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :update, :create, :destroy, :to => :touch

    user ||= User.new # guest user (not logged in)
    if user.admin?
      can :manage, :all
    elsif user.judge?
      cannot :read, [Comment, Language, Page, Topic]
    else
      can :read, Problem {|problem| user.owns?(problem) || problem.public? }
      can :read, [Contest, Lesson, Topic, Comment, Language, Page]

      can :check, Solution, :user_id => user.id, :state => 'updated'
      can :read, Solution do |solution|
        user.owns?(solution) || user.solved?(solution.problem)
      end
    end
  end
end
