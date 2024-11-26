# frozen_string_literal: true

class Api::V1::AccountRequestsController < ApiController
  skip_before_action :doorkeeper_authorize!, only: :create
  skip_after_action :verify_authorized, only: :create
  skip_after_action :verify_policy_scoped, only: :pending_account_requests_count

  before_action :set_account_request, only: %i[show accept destroy]

  def index
    account_requests = policy_scope(AccountRequest)
    authorize account_requests

    render json: apply_fetcheable(account_requests).to_blueprint
  end

  def pending_account_requests_count
    authorize AccountRequest

    render json: { pending_account_requests_count: AccountRequest.where(accepted: false).count }
  end

  def show
    render json: @account_request.to_blueprint
  end

  def create
    account_request = AccountRequest.new(account_request_params)

    if account_request.save
      render json: account_request.to_blueprint, status: :created
    else
      render_validation_error(account_request)
    end
  end

  def accept
    result = AccountRequests::Accept.call(account_request: @account_request)

    if result.success?
      render json: result.success.to_blueprint, status: :ok
    else
      render_error(result.failure[:error], code: 422)
    end
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
    params.permit(:email, :first_name, :last_name, :comment, :laboratory, :password)
  end
end
