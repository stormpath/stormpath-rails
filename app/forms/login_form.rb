class LoginForm
  include ActiveModel::Model

  attr_accessor :login, :password

  validate :validate_login_and_password_presence

  private

  def validate_login_and_password_presence
    if login.blank? && password.blank?
      errors.add(:base, "Login and password fields can't be blank")
    elsif login.blank?
      errors.add(:base, "Login field can't be blank")
    elsif password.blank?
      errors.add(:base, "Password field can't be blank")
    end
  end
end
