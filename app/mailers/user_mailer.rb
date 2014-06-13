class UserMailer < ActionMailer::Base
  default from: "no-reply@example.com"

  def welcome(user)
    @user = user
    mail(to: @user.email, subject: 'Bienvenue sur \'Tu stages où ?\'')
  end
end
