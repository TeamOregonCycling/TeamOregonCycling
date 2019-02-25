class UpdateUser < ApplicationService
  input :user
  input :changes
  input :success, default: ->(user) { user }
  input :error, default: ->(user) {
    raise 'Unable to save changes due to errors. ' \
    "#{user.errors.full_messages.join(', ')}"
  }

  authorization_policy do
    tests = [require_permission(:update, on: :user)]
    if changes.key?(:roles) || changes.key?(:role_ids)
      tests << require_permission(:manage_users)
    end
    tests.all?
  end

  main do
    check_for_email_change
    update_user
    maybe_send_email_confirmation
    success!
  end

  private

  attr_accessor :email_changed

  def email_changed?
    email_changed
  end

  def user
    return @user if @user_loaded

    @user_loaded = true
    @user = User.find(user.to_param)
  end

  def check_for_email_change
    return if user.email == changes[:email]

    self.email_changed = true
    changes[:confirmed_at] = nil
  end

  def update_user
    return if user.update_attributes(changes)

    user.readonly!
    error.call(user)
    stop!
  end

  def maybe_send_email_confirmation
    return unless email_changed?

    call_service(SendEmailConfirmationToken, email: user.email)
  end

  def success!
    user.readonly!
    run_callback(success, user)
  end
end
