# frozen_string_literal: true

class PotBlueprint < Base
  # Fields
  fields :name, :area, :dimensions

  field :shape do |pot|
    if pot.shape.other?
      serialize_other_shape
    else
      JSON.parse(
        ShapeBlueprint.render("Shape::#{pot.shape.capitalize}".constantize)
      )
    end
  end
end
