# frozen_string_literal: true

class Api::V1::PotsController < ApiController
  # def index
  #   render json: apply_fetcheable(@pots).to_blueprint
  # end

  # def show
  #   render json: @pot.to_blueprint
  # end

  def create
    authorize Pot

    render_interactor_result(
      Pots::Create.call(pot_params.to_h),
      status: :created
    )
  end

  private

  def pot_params
    params.permit(:name, :area, :shape, dimensions: [])
  end
end
