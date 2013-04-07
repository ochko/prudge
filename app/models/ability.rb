class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :update, :create, :destroy, :to => :touch
    alias_action :update, :destroy, :to => :modify

    unless user
      # not logged in
      can :read, Page
      can :read, Lesson
      return
    end

    if user.admin?
      can :manage, :all
    elsif user.judge?
      can :read, [Comment, Language, Page, Topic]
      can :modify, Solution
    else
      can :read, Problem {|problem| user.owns?(problem) || problem.public? }
      can :read, [Contest, Lesson, Topic, Comment, Language, Page]

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

    can :create, Lesson
    can :modify, Lesson, :author_id => user.id
  end
end
