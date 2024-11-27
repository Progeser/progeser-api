# frozen_string_literal: true

class Api::V1::PasswordsController < ApiController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

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
