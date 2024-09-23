# frozen_string_literal: true

class ShapeBlueprint < Blueprinter::Base
  # Fields
  field :name do |shape|
    shape.to_s.demodulize.downcase
  end

  field :display_name do |shape|
    I18n.t(
      "shape.#{shape.to_s.demodulize.downcase}.name"
    )
  end

  field :dimension_names do |shape|
    shape::DIMENSIONS_NAMES.map do |dimension_name|
      I18n.t(
        "shape.#{shape.to_s.demodulize.downcase}.#{dimension_name}"
      )
    end
  end
end
