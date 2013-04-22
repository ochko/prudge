class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :update, :create, :destroy, :to => :touch
    alias_action :update, :destroy, :to => :modify

    can :read, Page
    can :read, Lesson
    can :read, Problem, ["active_from < ?", Time.now] do |problem|
      problem.publicized?
    end

    return unless user # not logged in

    if user.admin?
      can :manage, :all
    elsif user.judge?
      can [:read, :update, :check, :approve], Problem
      can :destroy, Problem do |problem|
        problem.solutions.count == 0
      end
      can [:modify, :check], Solution
    else
      can :read, Problem {|problem| problem.publicized? || user.owns?(problem) }
      can :update, Problem do |problem|
        user.owns?(problem) && !problem.publicized?
      end
      can :check, Solution, :user_id => user.id, :state => 'updated'
      can :modify, Solution do |solution|
        user.owns?(solution) && solution.open?
      end
      can :create, Solution do |solution|
        contest = solution.contest
        (contest.nil? || contest.finished? ||
         (contest.started? && contest.openfor?(user))) &&
          solution.fresh?
      end
    end
    # all users
    can :read, Solution do |solution|
      user.owns?(solution) ||
        (!solution.competing? && user.solved?(solution.problem))
    end

    cannot :check, Solution do |solution|
      solution.problem.tests.real.empty?
    end

    can :read, [Contest, Topic, Comment, Language]
    can :create, [Lesson, Problem]
    can :modify, Lesson, :author_id => user.id
  end
end
