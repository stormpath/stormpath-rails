class Stormpath::Rails::OmniauthController < Stormpath::Rails::BaseController
  def create
    result = create_omniauth_user('facebook', params[:access_token])

    # initialize_session user, result.account.href
    set_flash_message :notice, 'Successfully signed in'

    redirect_to root_path
  end
end
