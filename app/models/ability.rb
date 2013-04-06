class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :update, :create, :destroy, :to => :touch

    user ||= User.new # guest user (not logged in)
    if user.admin?
      can :manage, :all
    elsif user.judge?
      can :manage, :all
      cannot :destroy, Comment
      cannot :touch, Language
      cannot :touch, Page
      cannot :touch, Topic
    else
      can :read, Problem {|problem| user.owns?(problem) || problem.public? }
      can :read, Contest
      can :read, Lesson
      can :read, Topic
      can :read, Solution

      can :check, Solution, :user_id => user.id, :state => 'updated'
    end
  end
end
