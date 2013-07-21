class AdminAbility < UserAbility
  def initialize(user)
    can :manage, :all
    can :check, Solution

    super(user)
  end
end
