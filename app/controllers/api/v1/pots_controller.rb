# frozen_string_literal: true

class Api::V1::PotsController < ApiController
  before_action :set_pot, except: %i[index create]

  def index
    pots = policy_scope(Pot)
    authorize pots

    render json: apply_fetcheable(pots).to_blueprint
  end

  def show
    render json: @pot.to_blueprint
  end

  def create
    authorize Pot

    render_interactor_result(
      Pots::Create.call(pot_params.to_h),
      status: :created
    )
  end

  def update
    authorize @pot

    render_interactor_result(
      Pots::Update.call(pot: @pot, params: pot_params.to_h)
    )
  end

  def destroy
    if @pot.destroy
      head :no_content
    else
      render_validation_error(@pot)
    end
  end

  private

  def set_pot
    @pot = policy_scope(Pot).find(params[:id])
    authorize(@pot)
  end

  def pot_params
    params.permit(:name, :area, :shape, dimensions: [])
  end
end
