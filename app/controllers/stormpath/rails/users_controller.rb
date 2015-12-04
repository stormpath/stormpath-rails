class Stormpath::Rails::UsersController < Stormpath::Rails::BaseController
  def create
    @user = user_from_params
    result = create_stormpath_account @user

    if result.success?
      @user.save

      if configuration.verify_email.enabled?
        render template: "users/verification_email_sent"
      else
        initialize_session(@user, result.account.href)
        set_flash_message :notice, 'Your account was created successfully'
        redirect_to configuration.register.next_uri
      end
    else
      set_flash_message :error, result.error_message
      render template: "users/new"
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
    email = user_params.delete(:email)
    password = user_params.delete(:password)
    given_name = user_params.delete(:given_name)
    surname = user_params.delete(:surname)

    ::User.new.tap do |user|
      user.email = email
      user.password = password
      user.given_name = given_name
      user.surname = surname
    end
  end

  def user_params
    params[:user] || Hash.new
  end
end
