# frozen_string_literal: true

class ShapedRecords::Create < ApplicationInteractor
  shaped_record_input

  around :database_transaction!
  step :validate_input!

  try :create_record!, catch: [
    Shape::InvalidKind,
    Shape::InvalidDimensionsNumber,
    ActiveRecord::RecordInvalid
  ]

  def create_record!(record:, params:)
    record.assign_attributes(
      Shape.format_params(params)
    )
    record.save!

    record
  end
end
