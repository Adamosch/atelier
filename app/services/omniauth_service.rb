class OmniauthService
  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first

    unless user
      user = User.create(
          email: data['email'],
          password: Devise.friendly_token[0, 20]
      )
    end
    user
  end
end