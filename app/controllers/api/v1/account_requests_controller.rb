# frozen_string_literal: true

class Api::V1::AccountRequestsController < ApiController
  skip_before_action :doorkeeper_authorize!, only: :create
  skip_after_action :verify_authorized, only: :create

  def create
    account_request = AccountRequest.new(account_request_params)

    if account_request.save
      render json: account_request.to_blueprint, status: :created
    else
      render_validation_error(account_request)
    end
  end

  private

  def account_request_params
    params.permit(%i[email first_name last_name comment])
  end
end
