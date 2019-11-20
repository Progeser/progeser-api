# frozen_string_literal: true

class AccountRequests::Accept < ApplicationInteractor
  input do
    schema do
      required(:account_request).filled(type?: AccountRequest)
    end
  end

  around :database_transaction!
  step :validate_input!

  try :accept!, catch: ActiveRecord::RecordInvalid
  tee :send_mail

  def accept!(account_request:)
    account_request.update!(accepted: true)

    account_request
  end

  def send_mail(account_request)
    UserMailer.accept_account_request(account_request.id).deliver_later
  end
end
