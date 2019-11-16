# frozen_string_literal: true

class Api::V1::UsersController < ApiController
  skip_before_action :doorkeeper_authorize!
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  # Accept invite
  def create_from_invite
    invite = Invite.find_by!(invitation_token: params[:invitation_token])

    render_interactor_result(
      Users::CreateFromInvite.call(user_params: user_params.to_h, invite: invite),
      status: :created,
      opts: { view: :with_token }
    )
  end

  private

  def user_params
    params.permit(%i[password password_confirmation])
  end
end
