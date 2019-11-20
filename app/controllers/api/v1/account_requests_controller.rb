# frozen_string_literal: true

class Api::V1::AccountRequestsController < ApiController
  skip_before_action :doorkeeper_authorize!, only: :create
  skip_after_action :verify_authorized, only: :create

  before_action :set_account_request, only: %i[accept destroy]

  def create
    account_request = AccountRequest.new(account_request_params)

    if account_request.save
      render json: account_request.to_blueprint, status: :created
    else
      render_validation_error(account_request)
    end
  end

  def accept
    render_interactor_result(
      AccountRequests::Accept.call(account_request: @account_request)
    )
  end

  def destroy
    if @account_request.destroy
      head :no_content
    else
      render_validation_error(@account_request)
    end
  end

  private

  def set_account_request
    @account_request = policy_scope(AccountRequest).find(params[:id])
    authorize(@account_request)
  end

  def account_request_params
    params.permit(%i[email first_name last_name comment])
  end
end
