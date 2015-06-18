class Stormpath::BaseController < ApplicationController
  protected

  def set_flash_message(key, message)
    flash[key] = message if message.present?
  end
end