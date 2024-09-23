# frozen_string_literal: true

class Users::CreateFromInvite < ApplicationInteractor
  input do
    schema do
      required(:user_params).hash do
        required(:password).filled
        required(:password_confirmation).filled
      end
      required(:invite).filled(type?: Invite)
    end
  end

  around :database_transaction!
  step :validate_input!

  try :create_user!, catch: ActiveRecord::RecordInvalid
  try :destroy_invite!, catch: ActiveRecord::RecordNotDestroyed
  try :create_token!, catch: ActiveRecord::RecordInvalid

  def create_user!(user_params:, invite:)
    user = User.create!(
      email: invite.email,
      role: invite.role,
      type: "Users::#{invite.role.capitalize}",
      first_name: invite.first_name,
      last_name: invite.last_name,
      laboratory: invite.laboratory,
      password: user_params[:password],
      password_confirmation: user_params[:password_confirmation]
    )

    { user:, invite: }
  end

  def destroy_invite!(user:, invite:)
    invite.destroy!

    user
  end

  def create_token!(user)
    user.create_token!

    user
  end
end
