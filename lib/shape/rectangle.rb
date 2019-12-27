# frozen_string_literal: true

class Shape::Rectangle < Shape
  DIMENSIONS_NAMES = %w[width height].freeze

  def self.area(width, height)
    width * height
  end
end
