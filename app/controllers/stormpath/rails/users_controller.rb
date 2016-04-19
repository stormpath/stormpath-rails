class Stormpath::Rails::UsersController < Stormpath::Rails::BaseController
  def create
    @user = user_from_params
    result = create_stormpath_account @user

    if result.success?
      @user.save

      if configuration.verify_email.enabled?
        respond_to do |format|
          format.json { render json: @user }
          format.html { render template: "users/verification_email_sent" }
        end
      else
        initialize_session(@user, result.account.href)

        respond_to do |format|
          format.json { render json: @user }
          format.html do
            set_flash_message :notice, 'Your account was created successfully'
            redirect_to configuration.register.next_uri
          end
        end
      end
    else
      respond_to do |format|
        format.json { render json: { error: result.error_message }, status: 400 }
        format.html do
          set_flash_message :error, result.error_message
          render template: "users/new"
        end
      end
    end
  end

  def new
    if configuration.id_site.enabled?
      redirect_to id_site_register_url
    else
      if signed_in?
        redirect_to root_path
      else
        @user = user_from_params
        render template: "users/new"
      end
    end
  end

  def profile
    if signed_in?
      account = get_account current_user_href
      render json: account.properties
    else
      render nothing: true, status: 401
    end
  end

  def verify
    result = verify_email_token params[:sptoken]

    if result.success?
      @account_url = result.account_url
      render template: "users/verification_complete"
    else
      render template: "users/verification_failed"
    end
  end

  private

  def user_from_params
    @user_from_params ||= ::User.new.tap do |user|
      user.email = params[:email]
      user.password = params[:password]
      user.given_name = params[:givenName]
      user.surname = params[:surname]
    end
  end
end
