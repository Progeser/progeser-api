# frozen_string_literal: true

class Api::V1::GreenhousesController < ApiController
  before_action :set_greenhouse, except: %i[index create]

  def index
    greenhouses = policy_scope(Greenhouse)
    authorize greenhouses

    render json: apply_fetcheable(greenhouses).to_blueprint
  end

  def show
    render json: @greenhouse.to_blueprint
  end

  def create
    authorize Greenhouse

    greenhouse = Greenhouse.new(greenhouse_params)

    if greenhouse.save
      render json: greenhouse.to_blueprint, status: :created
    else
      render_validation_error(greenhouse)
    end
  end

  def update
    if @greenhouse.update(greenhouse_params.merge(occupancy: @greenhouse.compute_occupancy))
      render json: @greenhouse.to_blueprint
    else
      render_validation_error(@greenhouse)
    end
  end

  def destroy
    if @greenhouse.destroy
      head :no_content
    else
      render_validation_error(@greenhouse)
    end
  end

  private

  def set_greenhouse
    @greenhouse = policy_scope(Greenhouse).find(params[:id])
    authorize(@greenhouse)
  end

  def greenhouse_params
    params.permit(%i[name width height])
  end
end
