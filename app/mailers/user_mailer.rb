# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def confirmation(user)
    @user = user
    mail(to: @user.email_address, subject: 'Confirm Your Account')
  end
end
