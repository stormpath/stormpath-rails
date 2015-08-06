class Stormpath::Rails::SessionsController < Stormpath::Rails::BaseController
  def create
    @user = find_user_by_email params[:session][:email]
    if @user
      result = authenticate @user

      redirect_to root_path, notice: 'Successfully signed in'
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