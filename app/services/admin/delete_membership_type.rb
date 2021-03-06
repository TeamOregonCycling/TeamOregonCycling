module Admin
  class DeleteMembershipType < ApplicationService
    input :membership_type
    input :success, default: ->(membership_type) { membership_type }

    require_permission :manage_users

    main do
      membership_type.discard
      success.call(membership_type)
    end

    private

    def membership_type
      return @membership_type if @membership_type.is_a?(MembershipType)
      @membership_type = MembershipType.find(@membership_type)
    end
  end
end
