class HomeController < ApplicationController

  def index
    begin
      @user = params[:token] ? User.find_by(token: params[:token]) : User.new
    rescue Mongoid::Errors::DocumentNotFound
      @user = User.new
    end
    @users = User.all
  end

end
