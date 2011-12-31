class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    cannot :manage, :all
    can :show, Event
    if user.role? :admin
      can :manage, :all
    elsif user.role? :promoter
      can :manage, Event, :user_id => user.id
    end
  end
end
