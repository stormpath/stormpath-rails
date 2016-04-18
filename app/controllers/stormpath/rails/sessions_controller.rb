class Stormpath::Rails::SessionsController < Stormpath::Rails::BaseController
  before_filter :redirect_signed_in_users, only: :new

  def create
    result = authenticate user_from_params

    if result.success?
      @user = find_or_create_user_from_account result.account
      initialize_session(@user, result.account.href)

      respond_to do |format|
        format.json { render json: login_serializer(result.account) }
        format.html { redirect_to login_redirect_route, notice: 'Successfully signed in' }
      end
    else
      respond_to do |format|
        format.json { render json: { status: 400, message: result.error_message }, status: 400 }
        format.html do
          set_flash_message :error, result.error_message
          render template: "sessions/new"
        end
      end
    end
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
    initialize_session(@user, user_data.href)

    redirect_to configuration.id_site.next_uri, notice: 'Successfully signed in'
  end

  private

  def user_from_params
    if params[:session].nil?
      username = params[:username] || params[:email]
      password = params[:password]
    else
      username = params[:session][:username] || params[:session][:email]
      password = params[:session][:password]
    end

    ::User.new.tap do |user|
      user.email = username
      user.password = password
    end
  end

  def redirect_signed_in_users
    redirect_to root_path if signed_in?
  end

  def login_redirect_route
    if params[:next]
      login_redirect_route_from_params
    else
      configuration.login.next_uri
    end
  end

  def login_redirect_route_from_params
    if params[:next].start_with?('/')
      params[:next]
    else
      "/#{params[:next]}"
    end
  end

  def login_serializer(account)
    {
      account: {
        href: account.href,
        username: account.username,
        modifiedAt: nil, #account.modified_at,
        status: account.status,
        createdAt: nil, #account.created_at,
        email: account.email,
        middleName: account.middle_name,
        surname: account.surname,
        givenName: account.given_name,
        fullName: account.full_name
      }
    }
  end
end
