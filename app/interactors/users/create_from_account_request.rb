# frozen_string_literal: true

class Users::CreateFromAccountRequest < ApplicationInteractor
  input do
    schema do
      required(:user_params).hash do
        required(:laboratory).filled
        required(:password).filled
        required(:password_confirmation).filled
      end
      required(:account_request).filled(type?: AccountRequest)
    end
  end

  around :database_transaction!
  step :validate_input!

  try :create_user!, catch: ActiveRecord::RecordInvalid
  try :destroy_account_request!, catch: ActiveRecord::RecordNotDestroyed
  try :create_token!, catch: ActiveRecord::RecordInvalid

  def create_user!(user_params:, account_request:)
    user = Users::Requester.create!(
      email: account_request.email,
      role: :requester,
      first_name: account_request.first_name,
      last_name: account_request.last_name,
      laboratory: user_params[:laboratory],
      password: user_params[:password],
      password_confirmation: user_params[:password_confirmation]
    )

    { user:, account_request: }
  end

  def destroy_account_request!(user:, account_request:)
    account_request.destroy!

    user
  end

  def create_token!(user)
    user.create_token!

    user
  end
end
