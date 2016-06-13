module ConfigSpecHelpers
  def enable_profile
    web_config.me.enabled = true
  end

  def disable_profile
    web_config.me.enabled = false
  end

  def enable_forgot_password
    web_config.forgot_password.enabled = true
  end

  def disable_forgot_password
    web_config.forgot_password.enabled = false
  end

  def enable_change_password
    web_config.change_password.enabled = true
  end

  def disable_change_password
    web_config.change_password.enabled = false
  end

  def disable_facebook_login
    web_config.facebook.app_id = ''
    web_config.facebook.app_secret = ''
  end

  def enable_facebook_login
    web_config.facebook.app_id = 'test_app_id'
    web_config.facebook.app_secret = 'dk2k152msj'
  end

  def enable_id_site
    web_config.id_site.enabled = true
    web_config.id_site.uri = '/redirect'
    web_config.id_site.next_uri = '/'
  end

  def disable_id_site
    web_config.id_site.enabled = false
  end

  def configuration
    Stormpath::Rails.config
  end

  def config_not_specified
    disable_forgot_password
    disable_facebook_login
    disable_id_site
    disable_verify_email
  end

  def enable_verify_email
    web_config.verify_email.enabled = true
  end

  def disable_verify_email
    web_config.verify_email.enabled = false
  end

  def web_config
    Stormpath::Rails.config.web
  end

  def reload_form_class
    Stormpath::Rails.send(:remove_const, 'RegistrationForm') if defined?(Stormpath::Rails::RegistrationForm)
    load('stormpath/rails/registration_form.rb')
  end
end
