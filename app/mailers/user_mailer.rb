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

  def accept_account_request(account_request_id)
    account_request = AccountRequest.find(account_request_id)

    send_mail(
      receiver_email: account_request.email,
      subject: t('mailers.clearance_mailer.account_request.subject'),
      template_id: 1_096_237,
      variables: account_request_variables(account_request)
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

  def account_request_variables(account_request)
    {
      first_name: account_request.first_name,
      last_name: account_request.last_name,
      url: frontend_url(
        t('mailers.clearance_mailer.account_request.path'),
        account_request.creation_token
      )
    }
  end
end
