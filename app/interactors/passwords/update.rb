# frozen_string_literal: true

class Passwords::Update < ApplicationInteractor
  input do
    schema do
      required(:password_params).hash do
        required(:password).filled
        required(:password_confirmation).filled
      end
      required(:user).filled(type?: User)
    end
  end

  around :database_transaction!
  step :validate_input!

  try :update_password!, catch: ActiveRecord::RecordInvalid

  def update_password!(password_params:, user:)
    user.update_password!(**password_params)

    user
  end
end
