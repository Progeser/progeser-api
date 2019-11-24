# frozen_string_literal: true

class PasswordMailer < ApplicationMailer
  def reset_password(user_id)
    user = User.find(user_id)

    variables = {
      first_name: user.first_name,
      last_name: user.last_name,
      url: frontend_url(
        t('mailers.password_mailer.reset_password.path'),
        user.confirmation_token
      )
    }

    send_mail(
      receiver_email: user.email,
      subject: t('mailers.password_mailer.reset_password.subject'),
      template_id: 1_098_517,
      variables: variables
    )
  end
end
