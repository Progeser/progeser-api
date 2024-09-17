# frozen_string_literal: true

class Invites::Create < ApplicationInteractor
  input do
    schema do
      required(:email).filled(:string)
      required(:role).filled(:string)
      optional(:first_name).filled(:string)
      optional(:last_name).filled(:string)

      optional(:laboratory).filled(:string)
    end
  end

  around :database_transaction!
  step :validate_input!

  try :create_invite!, catch: ActiveRecord::RecordInvalid
  tee :send_mail

  def create_invite!(invite_params)
    Invite.create!(invite_params)
  end

  def send_mail(invite)
    UserMailer.invite(invite.id).deliver_later
  end
end
