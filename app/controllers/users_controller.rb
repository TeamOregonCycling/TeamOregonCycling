class UsersController < ApplicationController
  attr_accessor :user, :memberships
  private :user=, :memberships=

  def new
    if ENV['SIGN_UP_ENABLED'] == 'false'
      redirect_to page_path(:join_team)
      return
    end
    render locals: { user: NewUserForm.new }
  end

  def create
    self.user = NewUserForm.new(
      params
      .require(:new_user)
      .permit(*NewUserForm::FIELDS)
    )

    validate_recaptcha!

    return account_creation_error(user.errors) unless user.valid?

    call_service(CreateUserAccount,
                 account_details: user,
                 success: callback(:account_created),
                 error: callback(:account_creation_error))
  end

  callback :account_created do |user|
    flash[:info] = render_to_string(partial: 'account_created_flash', locals: {user: user})
    session[:post_authentication_url] = new_membership_path
    redirect_to email_confirmation_path
  end

  callback :account_creation_error do |errors|
    user.errors = errors
    flash.now[:error] = 'There was an error while creating your account.'
    render action: :new, locals: { user: user }
  end

  def show
    require_permission(:show, on: current_user)
    self.user = current_user
    call_service(ListMembershipHistory,
                 user: current_user, with_result: method(:memberships=))
  end

  def edit
    render locals: { user: current_user }
  end

  def update
    account_details = params
      .require(:user)
      .permit(:email, :password, :password_confirmation, :first_name,
              :last_name, :profile_image, :profile_image_cache, :bio)

    call_service(UpdateUser,
                 user: current_user,
                 changes: account_details,
                 success: callback(:user_updated),
                 error: callback(:user_update_failed))
  end

  callback(:user_updated) do |user|
    flash[:info] = 'Account details updated.'
    redirect_to user_path
  end

  callback(:user_update_failed) do |user|
    flash[:error] = 'Your account could not be updated.'
    render action: :edit, locals: { user: user }
  end

  private

  def validate_recaptcha!
    return if NewGoogleRecaptcha.human?(params[:new_google_recaptcha_token],
                                        'create_account')

    account_creation_error(user.errors)
    halt!
  end
end
