module ConfigSpecHelpers
  def enable_forgot_password
    Stormpath::Rails.configure({
      web: { forgot_password: { enabled: true } }
    })
  end

  def disable_forgot_password
    Stormpath::Rails.configure({
      web: { forgot_password: { enabled: false } }
    })
  end

  def disable_facebook_login
    Stormpath::Rails.configure({
      social: { facebook: {} }
    })
  end

  def enable_facebook_login
    Stormpath::Rails.configure({
      social: { facebook: { app_id: "test_app_id" } }
    })
  end

  def enable_id_site
    Stormpath::Rails.configure({
      web: { id_site: {
        enabled: true,
        uri: "/redirect"
      } }
    })
  end

  def disable_id_site
    Stormpath::Rails.configure({
      web: { id_site: { enabled: false } }
    })
  end

  def config_not_specified
    Stormpath::Rails.configure({
      web: {
        id_site: {},
        verify_email: {},
        forgot_password: {}
      }
    })
  end

  def enable_verify_email
    Stormpath::Rails.configure({
      web: { verify_email: { enabled: true } }
    })
  end

  def disable_verify_email
    Stormpath::Rails.configure({
      web: { verify_email: { enabled: false } }
    })
  end
end

RSpec.configure do |config|
  config.include ConfigSpecHelpers
end
