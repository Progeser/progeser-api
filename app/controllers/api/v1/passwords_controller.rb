# frozen_string_literal: true

class Api::V1::PasswordsController < ApiController
  skip_before_action :doorkeeper_authorize!, only: %i[forgot reset]
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def forgot
    user = User.find_by!(email: params[:email])

    if user.forgot_password!
      PasswordMailer.reset_password(user.id).deliver_later
      head :no_content
    else
      render_error('an unknown error occured', code: 422)
    end
  end

  def reset
    user = User.find_by!(confirmation_token: params[:confirmation_token])

    render_interactor_result(
      Passwords::Reset.call(password_params: password_params.to_h, user: user),
      opts: { view: :with_token }
    )
  end

  def update
    unless current_user.authenticated?(params[:current_password])
      return render_error('invalid current password', code: 403)
    end

    render_interactor_result(
      Passwords::Update.call(password_params: password_params.to_h, user: current_user),
      status: :no_content
    )
  end

  private

  def password_params
    params.permit(%i[password password_confirmation])
  end
end
