class Stormpath::Rails::PasswordsController < Stormpath::Rails::BaseController
  before_filter :redirect_password_reset_disabled, only: :forgot

  def create
    if find_user_by_email(params[:password][:email])
      reset_password(params[:password][:email])
      render template: 'passwords/create'
    else
      render template: 'passwords/new'
    end
  end

  def forgot
    render template: 'passwords/forgot'
  end

  private

  def redirect_password_reset_disabled
    redirect_to root_path unless Stormpath::Rails.config.enable_forgot_password
  end
end