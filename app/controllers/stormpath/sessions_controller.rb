class Stormpath::SessionsController < Stormpath::BaseController
  def create
    @user = find_user params[:session][:email]
    if @user
      result = authenticate @user
      initialize_session @user.email, result.account.href

      set_flash_message :notice, 'Successfully signed in'
      redirect_to root_path
    else
      set_flash_message :notice, 'User not found'
      render template: "sessions/new"
    end
  end

  def new
    render template: "sessions/new"
  end
end