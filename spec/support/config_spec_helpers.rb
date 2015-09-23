module ConfigSpecHelpers
  def enable_forgot_password
    Stormpath::Rails.config.forgot_password.enabled = true
  end

  def disable_forgot_password
    Stormpath::Rails.config.forgot_password.enabled = false
  end

  def disable_facebook_login
    Stormpath::Rails.config.facebook.app_id = ''
    Stormpath::Rails.config.facebook.app_secret = ''
  end

  def enable_facebook_login
    Stormpath::Rails.config.facebook.app_id = 'test_app_id'
    Stormpath::Rails.config.facebook.app_secret = 'dk2k152msj'
  end

  def enable_id_site
   Stormpath::Rails.config.id_site.enabled = true
   Stormpath::Rails.config.id_site.uri = "/redirect"
   Stormpath::Rails.config.id_site.next_uri = "/"
  end

  def disable_id_site
    Stormpath::Rails.config.id_site.enabled = false
  end

  def config_not_specified
    disable_forgot_password
    disable_facebook_login
    disable_id_site
    disable_verify_email
  end

  def enable_verify_email
    Stormpath::Rails.config.verify_email.enabled = true
  end

  def disable_verify_email
    Stormpath::Rails.config.verify_email.enabled= false
  end
end

RSpec.configure do |config|
  config.include ConfigSpecHelpers
end
