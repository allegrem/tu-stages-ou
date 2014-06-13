class UserMailer < ActionMailer::Base
  default from: ENV['MAIL_FROM']

  def welcome(user)
    @user = user
    mail(to: @user.email, subject: 'Bienvenue sur \'Tu stages où ?\'')
  end
end
