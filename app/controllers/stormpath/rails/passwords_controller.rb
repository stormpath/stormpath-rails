class Stormpath::Rails::PasswordsController < Stormpath::Rails::BaseController
  before_filter :redirect_password_reset_disabled, only: :forgot

  def forgot_send
    result = reset_password(params[:password][:email])

    if result.success?
      render template: 'passwords/email_sent'
    else
      set_flash_message :error, "Invalid email address."
      render template: 'passwords/forgot'
    end
  end

  def forgot
    render template: 'passwords/forgot'
  end

  def forgot_change
    result = verify_email_token params[:sptoken]

    if result.success?
      render template: "passwords/forgot_change"
    else
      render template: "passwords/forgot_change_failed"
    end
  end

  private

  def redirect_password_reset_disabled
    redirect_to root_path unless Stormpath::Rails.config.enable_forgot_password
  end
end