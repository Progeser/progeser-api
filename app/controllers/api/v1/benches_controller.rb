# frozen_string_literal: true

class Api::V1::BenchesController < ApiController
  before_action :set_greenhouse, only: %i[index create]
  before_action :set_bench,      only: %i[show update destroy]

  def index
    benches = policy_scope(@greenhouse.benches)
    authorize benches

    render json: apply_fetcheable(benches).to_blueprint
  end

  def show
    render json: @bench.to_blueprint
  end

  def create
    authorize Bench

    render_interactor_result(
      ShapedRecords::Create.call(record: @greenhouse.benches.new, params: bench_params.to_h),
      status: :created
    )
  end

  def update
    render_interactor_result(
      ShapedRecords::Update.call(record: @bench, params: bench_params.to_h)
    )
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
    params.permit(:name, :area, :shape, dimensions: [])
  end
end
