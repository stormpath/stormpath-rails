class Stormpath::BaseController < ApplicationController
  private

  def set_flash_message(key, message)
    flash[key] = message if message.present?
  end
end