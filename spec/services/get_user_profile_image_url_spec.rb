require 'securerandom'
require 'services/get_user_profile_image_url'

RSpec.describe GetUserProfileImageURL do
  let(:service_args) {{
    user: user
  }}

  let(:user) {
    instance_double('User', email: user_email, gravatar_enabled?: true,
                    gravatar_disabled?: false)
  }

  let(:user_email) { "user.#{SecureRandom.hex(4)}@example.com" }

  service_double(:get_user, 'GetUser')

  it 'gets the specified user' do
    subject.call
    expect(get_user).to have_received_service_call(user: user)
  end

  shared_examples_for :it_provides_the_anonymous_user_image do
    specify do
      expect(subject.call).to eq 'https://gravatar.com/avatar/8c5548eb0b2b80924f237953392df5e7?s=100&d=mp&f=y'
    end
  end

  shared_examples_for :it_provides_the_users_image do
    specify do
      email_md5 = Digest::MD5.hexdigest(user_email)
      expect(subject.call).to eq "https://gravatar.com/avatar/#{email_md5}?s=100&d=mp"
    end
  end

  context 'if the user is not found' do
    before do
      allow(get_user).to receive(:call).and_return(nil)
    end

    it_behaves_like :it_provides_the_anonymous_user_image
  end

  context 'if the user is found' do
    before do
      allow(get_user).to receive(:call).and_return(user)
    end

    it_behaves_like :it_provides_the_users_image

    context 'if an admin has disabled the users gravatar' do
      before do
        allow(user).to receive(:gravatar_enabled?).and_return(false)
      end

      it_behaves_like :it_provides_the_anonymous_user_image

      context 'if show_disabled is true' do
        before do
          service_args[:show_disabled] = true
        end

        it_behaves_like :it_provides_the_users_image
      end
    end
  end
end
