class UsersController < ApplicationController

  respond_to :json

  def index
    render json: User.all
  end

  def create
    params[:user][:email] += '@telecom-paristech.fr'  if params[:user][:email]
    @user = User.where(email: user_params[:email]).first || User.new
    new_user = @user.coordinates.nil?
    @user.assign_attributes user_params
    @user.coordinates_str = params[:user][:coordinates]  if params[:user][:coordinates]
    if @user.save
      UserMailer.welcome(@user).deliver  if new_user
      render json: @user, status: (new_user ? :created : :ok)
    else
      render json: @user.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to root_path, notice: "Ton marqueur a bien été supprimé."
  end


  private

  def user_params
    params.require(:user).permit [:email, :country, :city, :company]
  end

end
