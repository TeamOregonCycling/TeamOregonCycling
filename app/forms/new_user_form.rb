require 'active_model'

class NewUserForm
  include ActiveModel::Model

  attr_writer :errors

  FIELDS = :email, :password, :password_confirmation, :first_name, :last_name,
           :profile_image, :profile_image_cache, :bio

  attr_accessor *FIELDS

  def model_name
    ActiveModel::Name.new(self.class, nil, 'new_user')
  end

  def profile_image?
    !profile_image.nil?
  end

  def display_name
    ''
  end

  validates :email, :password, :password_confirmation, :first_name,
    :last_name,
    presence: true

  validates :password, confirmation: true

  validates :bio, length: { maximum: 500 }

  def to_h
    {
      email: email,
      password: password,
      first_name: first_name,
      last_name: last_name,
      profile_image: profile_image,
      profile_image_cache: profile_image_cache,
      bio: bio
    }
  end
end
