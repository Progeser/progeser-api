# frozen_string_literal: true

class Api::V1::MeController < ApiController
  skip_after_action :verify_policy_scoped

  def show
    authorize current_user

    render json: current_user.to_blueprint
  end

  def update
    authorize current_user

    if current_user.update(update_params)
      render json: current_user.to_blueprint
    else
      render_validation_error(current_user)
    end
  end

  def destroy
    authorize current_user

    if current_user.discard
      head :no_content
    else
      render_validation_error(current_user)
    end
  end

  private

  def update_params
    if current_user.requester?
      params.permit(%i[first_name last_name laboratory])
    else
      params.permit(%i[first_name last_name])
    end
  end
end
