# frozen_string_literal: true

class Pots::Update < ApplicationInteractor
  input do
    schema do
      required(:pot).filled(type?: Pot)
      required(:params).hash do
        required(:name).filled(:string)
        required(:shape).filled(:string)
        optional(:area).filled(:float)
        optional(:dimensions).filled(:array)
      end
    end
  end

  around :database_transaction!
  step :validate_input!

  try :update_pot!, catch: [
    Shape::InvalidKind,
    Shape::InvalidDimensionsNumber,
    ActiveRecord::RecordInvalid
  ]

  def update_pot!(pot:, params:)
    pot.update!(
      Shape.format_params(params)
    )

    pot
  end
end
