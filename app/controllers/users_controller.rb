class UsersController < ApplicationController

  def index
    render json: User.all
  end

  def create
    @user = User.new user_params
    if @user.save
      render nothing: true, status: :created
    else
      render json: @user.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
  end


  private

  def user_params
    params[:user][:email] += '@telecom-paristech.fr'  if params[:user][:email]
    params.require(:user).permit [:email, :country, :city, :company]
  end

end
