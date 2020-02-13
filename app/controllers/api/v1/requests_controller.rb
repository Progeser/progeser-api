# frozen_string_literal: true

class Api::V1::RequestsController < ApiController
  before_action :set_request, except: %i[index create]

  def index
    requests = policy_scope(Request)
    authorize requests

    render json: apply_fetcheable(requests).to_blueprint
  end

  def show
    render json: @request.to_blueprint
  end

  def create
    authorize Request

    request = Request.new(request_params.merge(author: current_user))

    plant_attributes_from_params(request)

    if current_user.grower?
      request.handler = current_user
      request.status = :accepted # is this really the end-logic?
    end

    if request.save
      render json: request.to_blueprint, status: :created
    else
      render_validation_error(request)
    end
  end

  def update
    @request.assign_attributes(request_params)

    plant_attributes_from_params(@request)

    if @request.save
      render json: @request.to_blueprint
    else
      render_validation_error(@request)
    end
  end

  def accept
    # TODO?
    # To accept a request, do we have to create request_distributions?
  end

  # def refuse
  #   if @request.update(status: :refused)
  #     render json: @request.to_blueprint
  #   else
  #     render_validation_error(@request)
  #   end
  # end

  def destroy
    if @request.destroy
      head :no_content
    else
      render_validation_error(@request)
    end
  end

  private

  def set_request
    @request = policy_scope(Request).find(params[:id])
    authorize(@request)
  end

  def request_params
    params.permit(
      :plant_stage_id, :name, :plant_name, :stage_name, :quantity, :due_date,
      :comment, :temperature, :photoperiod
    )
  end

  def plant_attributes_from_params(request)
    return if request_params[:plant_stage_id].blank?

    plant_stage = PlantStage.find(request_params[:plant_stage_id])
    request.stage_name = plant_stage.name
    request.plant_name = plant_stage.plant.name
  end
end
