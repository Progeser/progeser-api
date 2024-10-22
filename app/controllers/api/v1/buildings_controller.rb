# frozen_string_literal: true

class Api::V1::BuildingsController < ApplicationController
  include Pundit

  skip_before_action :verify_authenticity_token

  before_action :set_building, only: [:show, :update, :destroy]

  def index
    buildings = policy_scope(Building)
    authorize buildings
    render json: apply_fetcheable(buildings).to_blueprint, status: :ok
  end

  def show
    render json: @building.to_blueprint, status: :ok
  end

  def create
    building = Building.new(building_params)
    if building.save
      render json: @building.to_blueprint, status: :created
    else
      render_validation_error(@building)
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
    if @building.destroy
      head :no_content
    else
      render_validation_error(@building)
    end
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
