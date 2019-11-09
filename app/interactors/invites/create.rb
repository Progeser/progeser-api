# frozen_string_literal: true

class Invites::Create < ApplicationInteractor
  input do
    schema do
      required(:email).filled
      required(:role).filled
      required(:first_name).filled
      required(:last_name).filled

      optional(:laboratory)
    end
  end

  around :database_transaction!
  step :validate_input!

  try :create_invite!, catch: ActiveRecord::RecordInvalid
  tee :send_mail

  def create_invite!(invite_params)
    invite = Invite.create!(invite_params)
    invite
  end

  def send_mail(invite)
    ClearanceMailer.invite(invite.id).deliver_later
    invite
  end
end
