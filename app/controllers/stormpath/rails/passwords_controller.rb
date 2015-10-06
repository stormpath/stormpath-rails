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
      @account_url = result.account_url
      render template: "passwords/forgot_change"
    else
      render template: "passwords/forgot_change_failed"
    end
  end

  def forgot_update
    @account_url = params[:account_url]
    if passwords_match?
      result = update_password(params[:account_url], params[:password][:original])
      if result.success?
        render template: "passwords/forgot_complete"
      else
        set_flash_message :error, result.error_message
        render template: "passwords/forgot_change"
      end

    else
      set_flash_message :error, 'Passwords do not match.'
      render template: "passwords/forgot_change"
    end
  end

  private

  def passwords_match?
    params[:password][:original] == params[:password][:repeated]
  end

  def redirect_password_reset_disabled
    redirect_to root_path unless configuration.forgot_password.enabled
  end
end
