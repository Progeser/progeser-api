# frozen_string_literal: true

class Shape
  # Public class methods
  def self.to_blueprint(opts = {})
    ShapeBlueprint.render(descendants, opts)
  end

  def self.format_params(params)
    record_params = { name: params[:name], shape: params[:shape], dimensions: params[:dimensions] }

    if params[:area]
      record_params.merge(area: params[:area])
    else
      area = Shape.new(params[:shape]).area(params[:dimensions])
      record_params.merge(area:)
    end
  end

  # Public instance methods
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

  # Error classes
  class InvalidKind < ActiveRecord::ActiveRecordError
    def initialize(kind)
      message = "`#{kind}` value incorrect, type param should be in: #{Pot::SHAPE_KINDS}"

      super(message)
    end
  end

  class InvalidDimensionsNumber < ActiveRecord::ActiveRecordError
    def initialize(given_number, expected_number)
      message = 'Dimensions number is incorrect ' \
                "(given #{given_number}, expected #{expected_number})"

      super(message)
    end
  end
end
