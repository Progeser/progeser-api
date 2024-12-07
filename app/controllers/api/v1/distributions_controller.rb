# frozen_string_literal: true

class Api::V1::DistributionsController < ApiController
  before_action :set_greenhouse, only: %i[index]
  before_action :set_distribution, only: %i[show update destroy]

  def index
    benches = policy_scope(@greenhouse.benches)
    authorize benches

    distributions = policy_scope(Distribution.where(bench: benches))
    authorize distributions

    render json: distributions
  end

  def show
    render json: @distribution.to_blueprint
  end

  def create
    @distribution = Distribution.new(distribution_params)
    authorize @distribution

    if @distribution.save
      render json: @distribution.to_blueprint, status: :created
    else
      render json: @distribution.errors, status: :unprocessable_entity
    end
  end

  def update
    @distribution.assign_attributes(distribution_params)

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

  def set_greenhouse
    @greenhouse = policy_scope(Greenhouse).find(params[:greenhouse_id])
  end

  def set_distribution
    @distribution = policy_scope(Distribution).find(params[:id])
    authorize(@distribution)
  end

  def distribution_params
    params.permit(
      :request_distribution_id,
      :bench_id,
      :pot_id,
      :seed_quantity,
      positions_on_bench: [],
      dimensions: []
    )
  end
end
