class Ability
  include CanCan::Ability

  def initialize(user)
    if user.has_role? :admin
      can :manage, :all
    else
      can :read, Brand
      can :read, BusinessHour
      can :read, Category
      can :read, Component
      can :read, ComponentModel
      can :read, Kit
      can :read, Location
      can :read, Reservation
#      can :manage, Reservation { |r| r.try(:client) == user }
    end
  end

end
