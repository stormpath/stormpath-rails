class Stormpath::SessionsController < Stormpath::BaseController
  def new
    render template: "sessions/new"
  end
end