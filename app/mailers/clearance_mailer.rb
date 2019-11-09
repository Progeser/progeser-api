# frozen_string_literal: true

class ClearanceMailer < ApplicationMailer
  def invite(invite_id)
    invite = Invite.find(invite_id)

    variables = {
      first_name: invite.first_name,
      last_name: invite.last_name,
      url: frontend_url(
        t('mailers.clearance_mailer.invite.path'),
        invite.invitation_token
      )
    }

    send_mail(
      receiver_email: invite.email,
      subject: t('mailers.clearance_mailer.invite.subject'),
      template_id: 1_062_641,
      variables: variables
    )
  end

  private

  def frontend_url(path, token)
    URI::HTTPS.build(
      host: ENV['FRONT_BASE_URL'],
      path: path + URI.encode_www_form(token: token)
    ).to_s
  end
end
