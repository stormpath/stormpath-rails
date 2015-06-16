class Stormpath::UsersController < Stormpath::BaseController
  def create
    @user = User.new(user_params)
    binding.pry

    if @user.save
      sign_in @user
      redirect_to root_path
    else
      render template: "users/new"
    end
  end

  def new
    @user = User.new
    render template: "users/new"
  end

  private

  def user_params
    params[:user] || Hash.new
  end
end