# frozen_string_literal: true

class Api::V1::PlantsController < ApiController
  before_action :set_plant, except: %i[index create]

  def index
    plants = policy_scope(Plant)
    authorize plants

    render json: apply_fetcheable(plants).to_blueprint
  end

  def show
    render json: @plant.to_blueprint
  end

  def create
    authorize Plant

    plant = Plant.new(create_params)

    if plant.save
      render json: plant.to_blueprint, status: :created
    else
      render_validation_error(plant)
    end
  end

  def update
    if @plant.update(update_params)
      render json: @plant.to_blueprint
    else
      render_validation_error(@plant)
    end
  end

  def destroy
    if @plant.destroy
      head :no_content
    else
      render_validation_error(@plant)
    end
  end

  private

  def set_plant
    @plant = policy_scope(Plant).find(params[:id])
    authorize(@plant)
  end

  def create_params
    params.permit(
      :name,
      plant_stages_attributes: %i[name duration position]
    )
  end

  def update_params
    params.permit(
      :name,
      plant_stages_attributes: %i[id _destroy name duration position]
    )
  end
end
