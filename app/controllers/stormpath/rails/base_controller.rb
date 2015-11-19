class Stormpath::Rails::BaseController < ApplicationController

  layout 'stormpath'

  private

  def api_request?
    request.content_type == "application/json"
  end

  def set_flash_message(key, message)
    flash[key] = message if message.present?
  end
end
