# frozen_string_literal: true

class Api::V1::BenchesController < ApiController
  before_action :set_greenhouse, only: %i[index create]
  before_action :set_bench, only: %i[show update destroy]

  def index
    benches = policy_scope(@greenhouse.benches)
    authorize benches

    render json: apply_fetcheable(benches).to_blueprint
  end

  def show
    render json: @bench.to_blueprint
  end

  def create
    @bench = @greenhouse.benches.new(bench_params)
    authorize @bench

    if @bench.save
      render json: @bench.to_blueprint, status: :created
    else
      render_validation_error(@bench)
    end
  end

  def update
    if @bench.update(bench_params)
      render json: @bench.to_blueprint
    else
      render_validation_error(@bench)
    end
  end

  def destroy
    if @bench.destroy
      head :no_content
    else
      render_validation_error(@bench)
    end
  end

  private

  def set_greenhouse
    @greenhouse = policy_scope(Greenhouse).find(params[:greenhouse_id])
  end

  def set_bench
    @bench = policy_scope(Bench).find(params[:id])
    authorize(@bench)
  end

  def bench_params
    params.permit(:name, dimensions: [])
  end
end
