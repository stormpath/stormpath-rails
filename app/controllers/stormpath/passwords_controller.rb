class Stormpath::PasswordsController < Stormpath::BaseController
  def create
    if find_user_by_email(params[:password][:email])
      reset_password(params[:password][:email])
      render template: 'passwords/new'
    end
    render template: 'passwords/new'
  end

  def new
    render template: 'passwords/new'
  end
end