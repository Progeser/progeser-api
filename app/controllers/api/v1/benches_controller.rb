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

    if overlapping_bench_exists?
      render json: { error: 'bench overlaps with an existing bench' }, status: :unprocessable_entity
    elsif @bench.save
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
    params.permit(:name, dimensions: [], positions: [])
  end

  def overlapping_bench_exists?
    new_bench_position = @bench.positions
    new_bench_dimensions = @bench.dimensions

    Bench.find_each do |bench|
      existing_bench_position = bench.positions
      existing_bench_dimensions = bench.dimensions

      if positions_overlap?(new_bench_position, new_bench_dimensions, existing_bench_position, existing_bench_dimensions)
        return true
      end
    end

    false
  end

  def positions_overlap?(pos1, dim1, pos2, dim2)
    x1, y1 = pos1
    width1, height1 = dim1
    x2, y2 = pos2
    width2, height2 = dim2

    x1 < x2 + width2 && x1 + width1 > x2 && y1 < y2 + height2 && y1 + height1 > y2
  end
end
