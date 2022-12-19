require "bcrypt"

class User < ApplicationRecord
  validates :username, :session_token, presence: true, uniqueness: true
  validates :password_digest, presence: true

  before_validation :ensure_session_token

  def self.find_by_credentials(username, password)
    user = User.find_by(username: username)
    user && user.is_password?(password) ? user : nil
  end

  attr_reader :password

  def password=(new_pass)
    self.password_digest = BCrypt::Password.create(new_pass) # NOTE: giving error

    @password = new_pass
  end

  def is_password?(other_pass) # password123 # f312137dshkjfsdh
    password_object = BCrypt::Password.new(self.password_digest)
    password_object.is_password?(other_pass)
  end

  def reset_session_token!
    self.session_token = self.generate_unique_session_token
    self.save!
    self.session_token
  end

  private

  def generate_unique_session_token
    # self.session_token = SecureRandom.urlsafe_base64
    SecureRandom.urlsafe_base64
  end

  def ensure_session_token
    self.session_token ||= self.generate_unique_session_token
  end
end
