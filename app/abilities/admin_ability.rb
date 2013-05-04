class AdminAbility < UserAbility
  def initialize(user)
    can :manage, :all

    super(user)
  end
end
