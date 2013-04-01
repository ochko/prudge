class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.admin?
      can :manage, :all
    elsif user.judge?
      can :manage, Solution
    else
      can :check, Solution, :user_id => user.id, :state => 'updated'
    end
  end
end
