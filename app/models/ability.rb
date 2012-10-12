class Ability
  include CanCan::Ability

  def initialize(user)
    if user.has_role? :admin
      can :manage, :all
    elsif user.has_role? :attendant
      can :read,   AppConfig
      can :manage, Brand
      can :read,   Budget
      can :manage, BusinessDay
      can :manage, BusinessHour
      can :manage, BusinessHourException
      can :manage, Category
      can :manage, Component
      can :manage, ComponentModel
      can :read,   Covenant
      can :read,   CovenantSignature
      can :manage, Group
      can :manage, Kit
      can :manage, Loan
      can :manage, Location
      can :manage, Membership
      can :manage, Permission
      can :read,   Role
      can :read,   User
    else
      can :read, Brand
      can :read, BusinessDay
      can :read, BusinessHour
      can :read, Category
      can :read, Component
      can :read, ComponentModel
      can :read, Kit
      can :read, Location
      can :read, Loan, :client_id => user.id
    end
  end

end
