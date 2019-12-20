# frozen_string_literal: true

class Pots::Create < ApplicationInteractor
  input do
    schema do
      required(:name).filled(:string)
      required(:shape).filled(:string)
      optional(:area).filled(:float)
      optional(:dimensions).filled(:array)
    end
  end

  around :database_transaction!
  step :validate_input!

  try :get_area!, catch: [Shape::InvalidKind, Shape::InvalidDimensionsNumber]
  try :create_pot!, catch: ActiveRecord::RecordInvalid

  def get_area!(params)
    pot_params = { name: params[:name], shape: params[:shape] }

    if params[:area]
      pot_params.merge(area: params[:area])
    else
      area = Shape.new(params[:shape]).area(params[:dimensions])
      pot_params.merge(area: area)
    end
  end

  def create_pot!(pot_params)
    Pot.create!(pot_params)
  end
end
