# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def invite(invite_id)
    invite = Invite.find(invite_id)

    send_mail(
      receiver_email: invite.email,
      subject: t('mailers.clearance_mailer.invite.subject'),
      template_id: 1_062_641,
      variables: invite_variables(invite)
    )
  end

  private

  def invite_variables(invite)
    {
      first_name: invite.first_name,
      last_name: invite.last_name,
      url: frontend_url(
        t('mailers.clearance_mailer.invite.path'),
        invite.invitation_token
      )
    }
  end
end
