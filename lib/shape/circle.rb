# frozen_string_literal: true

class Shape::Circle < Shape
  DIMENSIONS_NAMES = %w[diameter].freeze

  def self.area(diameter)
    diameter * Math::PI
  end
end
