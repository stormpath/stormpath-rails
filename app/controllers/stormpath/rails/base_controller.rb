class Stormpath::Rails::BaseController < ApplicationController

  layout 'stormpath'

  private

  def set_flash_message(key, message)
    flash[key] = message if message.present?
  end
end