# frozen_string_literal: true

class Api::V1::ShapesController < ApiController
  skip_after_action :verify_policy_scoped

  def index
    authorize Shape

    render json: Shape.to_blueprint
  end
end
