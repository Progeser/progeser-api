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

    if account_request.update(accepted: true)
      # Retourner un Success avec l'account_request mis à jour
      Success(account_request: account_request)
    else
      # Si la mise à jour échoue, retourner un Failure avec l'erreur
      Failure(error: account_request.errors.full_messages.join(', '))
    end
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
      Success(input)
    rescue ActiveRecord::RecordInvalid => e
      Failure(error: e.record.errors.full_messages.join(', '))
    end

  end
end
