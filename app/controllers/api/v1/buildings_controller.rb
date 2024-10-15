class Api::V1::BuildingsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_building, only: [:show, :update, :destroy]

  def index
    buildings = Building.all
    render json: buildings, status: :ok
  end

  def show
    render json: @building, status: :ok
  end

  def create
    building = Building.new(building_params)
    if building.save
      render json: building, status: :created
    else
      render json: { errors: building.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @building.update(building_params)
      render json: @building, status: :ok
    else
      render json: { errors: @building.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @building.destroy
    head :no_content
  end

  private

  def set_building
    @building = Building.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Building not found' }, status: :not_found
  end

  def building_params
    params.require(:building).permit(:name, :description)
  end
end
