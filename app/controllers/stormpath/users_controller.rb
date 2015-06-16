class Stormpath::UsersController < Stormpath::BaseController
  def create
    @user = user_from_params

    if @user.save
      sign_in @user
      redirect_to root_path
    else
      render template: "users/new"
    end
  end

  def new
    @user = user_from_params
    render template: "users/new"
  end

  private

  def user_from_params
    email = user_params.delete(:email)
    password = user_params.delete(:password)
    given_name = user_params.delete(:given_name)
    surname = user_params.delete(:surname)

    User.new(user_params).tap do |user|
      user.email = email
      user.password = password
      user.given_name = given_name
      user.surname = surname
    end
  end

  def user_params
    params[:user] || Hash.new
  end
end