class UserMailer < ActionMailer::Base
  default from: 'warsztaty@infakt.pl'
  layout 'mailer'

  def confirm_email(user, email)
    @user = user

    mail(to: email, subject: "Potwierdź adres email")
  end

  def take_email(user, book)
    @user = user
    @book = book
    mail(to: @user.email, subject: "Wypożyczyłeś książkę #{@book.title}")
  end

  def unsubscribe
  end
end