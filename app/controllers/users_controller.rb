class UsersController < ApplicationController

  def index
    render json: User.all
  end

  def create
    User.create! user_params
    render nothing: true, status: :created
  end

  def destroy
  end


  private

  def user_params
    params[:user][:email] += '@telecom-paristech.fr'  if params[:user][:email]
    params.require(:user).permit [:email, :country, :city, :company]
  end

end
