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

  try :create_pot!, catch: [
    Shape::InvalidKind,
    Shape::InvalidDimensionsNumber,
    ActiveRecord::RecordInvalid
  ]

  def create_pot!(params)
    Pot.create!(
      Shape.format_params(params)
    )
  end
end
