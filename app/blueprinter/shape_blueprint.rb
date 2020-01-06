# frozen_string_literal: true

class ShapeBlueprint < Blueprinter::Base
  # Fields
  field :name do |shape|
    I18n.t(
      "shape.#{shape.to_s.demodulize.downcase}.name"
    )
  end

  field :dimension_names do |shape|
    dimension_names = []

    shape::DIMENSIONS_NAMES.each do |dimension_name|
      dimension_names << I18n.t(
        "shape.#{shape.to_s.demodulize.downcase}.#{dimension_name}"
      )
    end

    dimension_names
  end
end
