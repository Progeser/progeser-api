# frozen_string_literal: true

class AccountRequests::Accept < ApplicationInteractor
  input do
    schema do
      required(:account_request).filled(type?: AccountRequest)
    end
  end

  around :database_transaction!
  step :validate_input!
  step :accept_request!
  step :create_user_from_request!

  def accept_request!(input)
    account_request = input[:account_request]
    account_request.update(accepted: true)
    Success(account_request:)
  end

  def create_user_from_request!(input)
    account_request = input[:account_request]
    user = Users::Requester.create!(
      email: account_request.email,
      role: :requester,
      first_name: account_request.first_name,
      last_name: account_request.last_name,
      laboratory: account_request.laboratory,
      encrypted_password: account_request.password_digest
    )
    Success(user:)
  rescue ActiveRecord::RecordInvalid => e
    Failure(error: e.record.errors.full_messages.join(', '))
  end
end
