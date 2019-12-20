# frozen_string_literal: true

class Shape::Triangle < Shape
  DIMENSIONS_NAMES = %w[base height].freeze

  def self.area(base, height)
    base * height / 2.0
  end
end
