# frozen_string_literal: true

class Shape::Square < Shape
  DIMENSIONS_NAMES = %w[side].freeze

  def self.area(side)
    side * side
  end
end
