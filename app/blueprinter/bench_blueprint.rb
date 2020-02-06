# frozen_string_literal: true

class BenchBlueprint < Base
  # Fields
  fields :name, :area, :dimensions

  field :shape do |bench|
    if bench.shape.other?
      serialize_other_shape
    else
      JSON.parse(
        ShapeBlueprint.render("Shape::#{bench.shape.capitalize}".constantize)
      )
    end
  end
end
