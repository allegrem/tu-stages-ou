class HomeController < ApplicationController

  def index
    begin
      @user = params[:id] ? User.find(params[:id]) : User.new
    rescue Mongoid::Errors::DocumentNotFound
      @user = User.new
    end
    @users = User.all
  end

end
