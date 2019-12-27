# frozen_string_literal: true

class ShapeBlueprint < Blueprinter::Base
  # Fields
  field :name do |shape|
    shape.to_s.demodulize.downcase
  end

  field :dimension_names do |shape|
    shape::DIMENSIONS_NAMES
  end
end
