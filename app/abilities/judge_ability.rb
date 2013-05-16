class JudgeAbility < UserAbility
  def initialize(user)
    can :read, :dashboard

    can [:manage, :check, :approve], Problem

    can [:modify, :check], Solution

    super(user)
  end
end
