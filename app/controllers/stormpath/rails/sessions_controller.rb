class Stormpath::Rails::SessionsController < Stormpath::Rails::BaseController
  before_filter :redirect_signed_in_users, only: :new

  def create
    result = authenticate user_from_params

    if result.success?
      @user = find_user_by_email params[:session][:email]
      initialize_session(@user)

      redirect_to configuration.login.next_uri, notice: 'Successfully signed in'
    else
      set_flash_message :error, result.error_message
      render template: "sessions/new"
    end
  end

  def destroy
    logout
    set_flash_message :notice, 'You have been logged out successfully.'
    redirect_to configuration.logout.next_uri
  end

  def new
    if !configuration.login.enabled?
      redirect_to configuration.login.next_uri 
    elsif configuration.id_site.enabled?
      redirect_to id_site_login_url
    else
      render template: "sessions/new"
    end
  end

  def redirect
    user_data = handle_id_site_callback(request.url)
    @user = find_user_by_email user_data.email
    initialize_session(@user)

    redirect_to configuration.id_site.next_uri, notice: 'Successfully signed in'
  end

  private

  def user_from_params
    ::User.new.tap do |user|
      user.email = params[:session][:email]
      user.password = params[:session][:password]
    end
  end

  def redirect_signed_in_users
    redirect_to root_path if signed_in?
  end
end
