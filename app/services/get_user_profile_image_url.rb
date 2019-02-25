class GetUserProfileImageURL < ApplicationService
  input :user
  input :show_disabled, default: false
  input :size, default: 100
  input :disabled, default: -> {}

  authorization_policy allow_all: true

  main do
    self.user = call_service(GetUser, user: user)
    run_callback(disabled) if user&.gravatar_disabled?
    force_default, email = if user && (user.gravatar_enabled? || show_disabled)
                             [false, user.email]
                           else
                             [true, 'nobody@example.com']
                           end
    email_md5 = Digest::MD5.hexdigest(email)
    url = "https://gravatar.com/avatar/#{email_md5}?s=#{size}&d=mp"
    url += '&f=y' if force_default
    self.result = url
  end
end
