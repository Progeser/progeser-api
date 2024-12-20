# frozen_string_literal: true

class Api::V1::BuildingsController < ApiController
  before_action :set_building, only: %i[show update destroy]

  def index
    buildings = policy_scope(Building)
    authorize buildings
    render json: apply_fetcheable(buildings).to_blueprint, status: :ok
  end

  def show
    render json: @building.to_blueprint, status: :ok
  end

  def create
    authorize Building
    building = Building.new(building_params)
    if building.save
      render json: building.to_blueprint, status: :created
    else
      render_validation_error(building)
    end
  end

  def update
    if @building.update(building_params)
      render json: @building.to_blueprint, status: :ok
    else
      render_validation_error(@building)
    end
  end

  def destroy
    @building.destroy
    head :no_content
  end

  private

  def set_building
    @building = policy_scope(Building).find(params[:id])
    authorize @building
  end

  def building_params
    params.require(:building).permit(%i[name description])
  end
end
