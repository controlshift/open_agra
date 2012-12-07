class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)
    if user.persisted?
      can :manage, Petition, user_id: user.id

      can :manage, Petition, campaign_admins: {user_id: user.id}

      can :manage, Group, users: {id: user.id}

      can :update, Petition, user_id: nil

      if user.org_admin?

        [Petition, User, Effort, Story, Group, Category, Member].each do | klass|
          can :manage, klass, organisation_id: user.organisation_id
        end

        can :manage, Organisation, id: user.organisation_id
      end

      if user.admin?
        can :manage, :all
      end
    end

    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, published: true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
