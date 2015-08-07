class Stormpath::Rails::PasswordsController < Stormpath::Rails::BaseController
  def create
    if find_user_by_email(params[:password][:email])
      reset_password(params[:password][:email])
      render template: 'passwords/create'
    else
      render template: 'passwords/new'
    end
  end

  def new
    render template: 'passwords/new'
  end
end