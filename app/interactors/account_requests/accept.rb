# frozen_string_literal: true

class AccountRequests::Accept < ApplicationInteractor
  input do
    schema do
      required(:account_request).filled(type?: AccountRequest)
    end
  end

  around :database_transaction!
  step :validate_input!

  try :accept_request!, catch: ActiveRecord::RecordInvalid
  try :create_user_from_request!, catch: ActiveRecord::RecordInvalid

  def accept_request!(input)
    account_request = input[:account_request]
    account_request.update!(accepted: true)

    { account_request: }
  end

  def create_user_from_request!(input)
    account_request = input[:account_request]
    begin
      Users::Requester.create!(
        email: account_request.email,
        role: :requester,
        first_name: account_request.first_name,
        last_name: account_request.last_name,
        laboratory: account_request.laboratory,
        encrypted_password: account_request.password_digest
      )
    rescue ActiveRecord::RecordInvalid => e
      return Failure(error: e.record.errors.full_messages.join(', '))
    end
    account_request
  end
end
