# frozen_string_literal: true

class ShapedRecords::Update < ApplicationInteractor
  shaped_record_input

  around :database_transaction!
  step :validate_input!

  try :update_record!, catch: [
    Shape::InvalidKind,
    Shape::InvalidDimensionsNumber,
    ActiveRecord::RecordInvalid
  ]

  def update_record!(record:, params:)
    record.update!(
      Shape.format_params(params)
    )

    record
  end
end
