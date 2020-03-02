# frozen_string_literal: true

class Api::V1::RequestDistributionsController < ApiController
  before_action :set_request,      only: %i[index create]
  before_action :set_distribution, only: %i[show update destroy]

  def index
    request_distributions = policy_scope(@request.request_distributions)
    authorize request_distributions

    render json: apply_fetcheable(request_distributions).to_blueprint
  end

  def show
    render json: @distribution.to_blueprint
  end

  def create
    authorize RequestDistribution

    distribution = @request.request_distributions.new(distribution_params)
    distribution.area = compute_area(distribution)

    if distribution.save
      render json: distribution.to_blueprint, status: :created
    else
      render_validation_error(distribution)
    end
  end

  def update
    @distribution.assign_attributes(distribution_params)
    @distribution.area = compute_area(@distribution)

    if @distribution.save
      render json: @distribution.to_blueprint
    else
      render_validation_error(@distribution)
    end
  end

  def destroy
    if @distribution.destroy
      head :no_content
    else
      render_validation_error(@distribution)
    end
  end

  private

  def set_request
    @request = policy_scope(Request).find(params[:request_id])
  end

  def set_distribution
    @distribution = policy_scope(RequestDistribution).find(params[:id])
    authorize(@distribution)
  end

  def distribution_params
    params.permit(:bench_id, :plant_stage_id, :pot_id, :pot_quantity)
  end

  def compute_area(distribution)
    return params[:area] if params[:area].present?

    pot_quantity = distribution.pot_quantity
    pot_area = distribution.pot&.area

    return if pot_quantity.nil? || pot_area.nil?

    pot_quantity * pot_area
  end
end
