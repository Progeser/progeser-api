# frozen_string_literal: true

class Api::V1::UsersController < ApiController
  skip_before_action :doorkeeper_authorize!,
                     only: %i[create_from_invite create_from_account_request]
  skip_after_action :verify_policy_scoped,
                    only: %i[create_from_invite create_from_account_request]

  def index
    users = policy_scope(User)
    authorize users

    render json: apply_fetcheable(users).to_blueprint
  end

  # Accept an invite and create a user
  #
  def create_from_invite
    invite = Invite.find_by!(invitation_token: params[:invitation_token])

    authorize invite, policy_class: UserPolicy

    render_invite_interactor_result(invite)
  end

  # Finalize user creation when an account request has been accepted
  #
  def create_from_account_request
    account_request = AccountRequest.find_by!(creation_token: params[:creation_token])

    authorize account_request, policy_class: UserPolicy

    render_account_request_interactor_result(account_request)
  end

  private

  def render_invite_interactor_result(invite)
    render_interactor_result(
      Users::CreateFromInvite.call(user_params: invite_params.to_h, invite:),
      status: :created,
      opts: { view: :with_token }
    )
  end

  def render_account_request_interactor_result(account_request)
    render_interactor_result(
      Users::CreateFromAccountRequest.call(
        user_params: account_request_params.to_h,
        account_request:
      ),
      status: :created,
      opts: { view: :with_token }
    )
  end

  def invite_params
    params.permit(%i[password password_confirmation])
  end

  def account_request_params
    params.permit(%i[laboratory password password_confirmation])
  end
end
