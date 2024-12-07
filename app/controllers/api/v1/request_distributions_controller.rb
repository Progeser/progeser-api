# frozen_string_literal: true

class Api::V1::RequestDistributionsController < ApiController
  before_action :set_request, only: %i[create]
  before_action :set_distribution, only: %i[show update destroy]

  def index
    request_distributions = policy_scope(RequestDistribution.all)
    authorize request_distributions

    render json: request_distributions.to_blueprint
  end

  def show
    render json: @request_distribution.to_blueprint
  end

  def create
    authorize RequestDistribution

    distribution = RequestDistribution.new(distribution_params)
    distribution.request = @request
    distribution.seeds_left_to_plant = @request.quantity

    if distribution.save
      render json: distribution.to_blueprint, status: :created
    else
      render_validation_error(distribution)
    end
  end

  def update
    @request_distribution.assign_attributes(distribution_params)

    if @request_distribution.save
      render json: @request_distribution.to_blueprint
    else
      render_validation_error(@request_distribution)
    end
  end

  def destroy
    if @request_distribution.destroy
      head :no_content
    else
      render_validation_error(@request_distribution)
    end
  end

  private

  def set_request
    @request = policy_scope(Request).find(params[:request_id])
  end

  def set_distribution
    @request_distribution = policy_scope(RequestDistribution).find(params[:id])
    authorize(@request_distribution)
  end

  def distribution_params
    params.permit(:plant_stage_id)
  end
end
