class UsersController < ApplicationController

  respond_to :json
  before_filter :find_user, only: [:update, :destroy]

  def index
    render json: User.all
  end

  def create
    @user = User.new user_params
    if @user.save
      UserMailer.welcome(@user).deliver
      render json: @user, status: :created
    else
      render json: @user.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    if @user.update user_params
      render json: @user, status: :ok
    else
      render json: @user.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to root_path, notice: "Ton marqueur a bien été supprimé."
  end


  private

  def user_params
    params.require(:user).permit [:login, :country, :city, :company, :coordinates_str]
  end

  def find_user
    @user = User.find_by token: params[:token]
  end

end
