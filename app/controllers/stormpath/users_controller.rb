class Stormpath::UsersController < Stormpath::BaseController
  def new
    render template: "users/new"
  end
end