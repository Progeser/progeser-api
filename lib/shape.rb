# frozen_string_literal: true

class Shape
  def initialize(kind)
    raise InvalidKind, kind unless Pot::SHAPE_KINDS.include?(kind)

    @shape = "Shape::#{kind.capitalize}".constantize
    @dimensions_names = @shape::DIMENSIONS_NAMES
  end

  def area(dimensions)
    if dimensions.length != @dimensions_names.length
      raise InvalidDimensionsNumber.new(dimensions.length, @dimensions_names.length)
    end

    @shape.area(*dimensions)
  end

  class InvalidKind < ActiveRecord::ActiveRecordError
    def initialize(kind)
      message = "`#{kind}` value incorrect, type param should be in: #{Pot::SHAPE_KINDS}"

      super(message)
    end
  end

  class InvalidDimensionsNumber < ActiveRecord::ActiveRecordError
    def initialize(given_number, expected_number)
      message = 'Dimensions number is incorrect '\
        "(given #{given_number}, expected #{expected_number})"

      super(message)
    end
  end
end
