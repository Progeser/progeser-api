# frozen_string_literal: true

class Api::V1::RequestsController < ApiController
  skip_after_action :verify_policy_scoped, only: :requests_to_handle_count
  skip_before_action :doorkeeper_authorize!, only: :create
  skip_after_action :verify_authorized, only: :create

  before_action :set_request, except: %i[index requests_to_handle_count create]

  filter_by :status, with: :eq

  sort_by :id,
          :created_at,
          :updated_at,
          :name,
          :plant_name,
          :status,
          :due_date

  def index
    requests = policy_scope(Request)
    authorize requests

    render json: apply_fetcheable(requests).to_blueprint
  end

  def requests_to_handle_count
    authorize Request

    render json: {
      pending_requests_count: Request.where(status: :pending).count,
      in_cancelation_requests_count: Request.where(status: :in_cancelation).count
    }
  end

  def show
    render json: @request.to_blueprint
  end

  def create
    request = Request.new(request_params)

    plant_attributes_from_params(request)

    if request.save
      render json: request.to_blueprint, status: :created
    else
      render_validation_error(request)
    end
  end

  def update
    @request.handler_id = current_user.id
    plant_attributes_from_params(@request)
    if @request.update(request_params)
      render json: @request.to_blueprint, status: :ok
    else
      render_validation_error(@request)
    end
  end

  def accept
    @request.handler_id = current_user.id
    if @request.fire_state_event(:accept)
      render json: @request.to_blueprint
    else
      render_validation_error(@request)
    end
  end

  def refuse
    @request.handler_id = current_user.id
    if @request.fire_state_event(:refuse)
      render json: @request.to_blueprint
    else
      render_validation_error(@request)
    end
  end

  def cancel
    @request.handler_id = current_user.id
    if @request.fire_state_event(:cancel)
      render json: @request.to_blueprint
    else
      render_validation_error(@request)
    end
  end

  def complete
    @request.handler_id = current_user.id
    if @request.fire_state_event(:complete)
      render json: @request.to_blueprint
    else
      render_validation_error(@request)
    end
  end

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
      :plant_stage_id, :plant_name, :plant_stage_name, :name, :quantity, :due_date,
      :comment, :temperature, :photoperiod, :requester_first_name, :requester_last_name,
      :requester_email, :laboratory
    )
  end

  def plant_attributes_from_params(request)
    return if request_params[:plant_stage_id].blank?

    plant_stage = policy_scope(PlantStage).find(request_params[:plant_stage_id])
    request.plant_stage_name = plant_stage.name
    request.plant_name = plant_stage.plant.name
  end
end
