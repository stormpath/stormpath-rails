class Stormpath::Rails::SessionsController < Stormpath::Rails::BaseController
  before_filter :redirect_signed_in_users, only: :new

  def create
    result = authenticate user_from_params

    if result.success?
      @user = find_user_by_email params[:session][:email]
      initialize_session(@user, result.account.href)

      respond_to do |format|
        format.json { render json: { user: @user } }
        format.html { redirect_to configuration.login.next_uri, notice: 'Successfully signed in' }
      end
    else
      respond_to do |format|
        format.json { render json: { error: result.error_message } }
        format.html do
          set_flash_message :error, result.error_message
          render template: "sessions/new"
        end
      end
    end
  end

  def destroy
    logout
    set_flash_message :notice, 'You have been logged out successfully.'
    redirect_to configuration.logout.next_uri
  end
  
  def destroy
    logout

    respond_to do |format|
      format.json { render nothing: true, status: 200 }
      format.html do
        set_flash_message :notice, 'You have been logged out successfully.'
        redirect_to configuration.logout.next_uri
      end
    end
  end

  def new
    if configuration.id_site.enabled?
      redirect_to id_site_login_url
    else
      render template: "sessions/new"
    end
  end

  def redirect
    user_data = handle_id_site_callback(request.url)
    @user = find_user_by_email user_data.email
    initialize_session(@user, user_data.href)

    redirect_to configuration.id_site.next_uri, notice: 'Successfully signed in'
  end

  private

  def user_from_params
    ::User.new.tap do |user|
      user.email = user_params[:email]
      user.password = user_params[:password]
    end
  end

  def user_params
    return params[:session] if params[:session]
    params
  end

  def redirect_signed_in_users
    redirect_to root_path if signed_in?
  end
end
