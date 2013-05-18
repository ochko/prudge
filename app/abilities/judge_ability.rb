class JudgeAbility < UserAbility
  def initialize(user)
    can :read, :dashboard

    can :manage, Contest

    can [:manage, :check, :approve], Problem

    can [:modify, :check], Solution

    can :read, Result

    super(user)
  end
end
