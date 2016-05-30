module ConfigSpecHelpers
  def enable_forgot_password
    Stormpath::Rails.config.web.forgot_password.enabled = true
  end

  def disable_forgot_password
    Stormpath::Rails.config.web.forgot_password.enabled = false
  end

  def enable_change_password
    Stormpath::Rails.config.web.change_password.enabled = true
  end

  def disable_change_password
    Stormpath::Rails.config.web.change_password.enabled = false
  end

  def disable_facebook_login
    Stormpath::Rails.config.web.facebook.app_id = ''
    Stormpath::Rails.config.web.facebook.app_secret = ''
  end

  def enable_facebook_login
    Stormpath::Rails.config.web.facebook.app_id = 'test_app_id'
    Stormpath::Rails.config.web.facebook.app_secret = 'dk2k152msj'
  end

  def enable_id_site
   Stormpath::Rails.config.web.id_site.enabled = true
   Stormpath::Rails.config.web.id_site.uri = "/redirect"
   Stormpath::Rails.config.web.id_site.next_uri = "/"
  end

  def disable_id_site
    Stormpath::Rails.config.web.id_site.enabled = false
  end

  def config_not_specified
    disable_forgot_password
    disable_facebook_login
    disable_id_site
    disable_verify_email
  end

  def enable_verify_email
    Stormpath::Rails.config.web.verify_email.enabled = true
  end

  def disable_verify_email
    Stormpath::Rails.config.web.verify_email.enabled= false
  end
end

RSpec.configure do |config|
  config.include ConfigSpecHelpers
end
