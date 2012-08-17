class Ability
  include CanCan::Ability

  def initialize(user)
    if user.has_role? :admin
      can :manage, :all
    else
      can :read, Model
#      can :manage, Reservation { |rez| rez.try(:client) == user }

    end
  end

end
