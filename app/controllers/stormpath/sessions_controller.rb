class Stormpath::SessionsController < Stormpath::BaseController
  def create
    @user = find_user_by_email params[:session][:email]
    if @user
      result = authenticate @user

      set_flash_message :notice, 'Successfully signed in'
      redirect_to root_path
    else
      set_flash_message :notice, 'User not found'
      render template: "sessions/new"
    end
  end

  def destroy
    logout
    set_flash_message :notice, 'You have been logged out successfully.'
    redirect_to root_url
  end

  def new
    render template: "sessions/new"
  end
end