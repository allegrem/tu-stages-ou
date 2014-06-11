class HomeController < ApplicationController

  def index
    @user = User.new
    @users = User.all
  end

end
