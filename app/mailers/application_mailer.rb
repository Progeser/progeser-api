# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAIL_FROM', nil)
  layout 'mailer'

  # rubocop: disable Metrics/MethodLength
  def send_mail(receiver_email:, subject:, template_id:, variables: {})
    Mailjet::Send.create(
      messages: [{
        From: {
          Email: ENV.fetch('MAIL_FROM', nil),
          Name: ENV.fetch('MAIL_SENDER_NAME', nil)
        },
        To: [{
          Email: receiver_email
        }],
        Subject: subject,
        TemplateLanguage: true,
        TemplateID: template_id,
        TemplateErrorDeliver: true,
        TemplateErrorReporting: {
          Email: 'tao.galasse@gmail.com',
          Name: '[ProGeSer] Mailjet Template Error Reporting'
        },
        Variables: variables
      }]
    )
  end
  # rubocop: enable Metrics/MethodLength

  private

  def frontend_url(path, token)
    URI::HTTPS.build(
      host: ENV.fetch('FRONT_BASE_URL', nil),
      path: path + token
    ).to_s
  end
end
