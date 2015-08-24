module ConfigSpecHelpers
  def enable_forgot_password
    Stormpath::Rails.configure({
      web: { forgot_password: { enabled: true } }
    })
  end

  def enable_id_site
    Stormpath::Rails.configure({
      web: { id_site: { enabled: true } }
    })
  end

  def enable_verify_email
    Stormpath::Rails.configure({
      web: { verify_email: { enabled: true } }
    })
  end

  def disable_forgot_password
    Stormpath::Rails.configure({
      web: { forgot_password: { enabled: false } }
    })
  end
end

RSpec.configure do |config|
  config.include ConfigSpecHelpers
end
