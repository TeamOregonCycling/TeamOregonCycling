module Admin
  class ListUsers < ApplicationService
    input :with_result, default: ->(users) { users }
    input :show, default: :current

    require_permission :manage_users

    main do
      users = User.kept.order(:last_name, :first_name)
                  .includes(:current_membership, :roles)
                  .readonly

      users = case show
              when :current
                users.joins(:current_membership)
                     .where('current_memberships.ends_on >= CURRENT_DATE')
              when :expired
                users.joins(:current_membership)
                     .where('current_memberships.ends_on < CURRENT_DATE')
              when :all
                users
              end
      with_result.call(users)
    end
  end
end
