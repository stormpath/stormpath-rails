module ConfigSpecHelpers
  def enable_forgot_password
    Stormpath::Rails.configure({
      web: {
        forgot_password: { enabled: true }
      }
    })
  end

  def disable_forgot_password
    Stormpath::Rails.configure({
      web: {
        forgot_password: { enabled: false }
      }
    })
  end
end

RSpec.configure do |config|
  config.include ConfigSpecHelpers
end
