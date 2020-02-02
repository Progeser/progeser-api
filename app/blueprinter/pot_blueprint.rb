# frozen_string_literal: true

class PotBlueprint < Base
  # Fields
  fields :name, :dimensions

  field :area do |pot|
    pot.area.round(2)
  end

  field :shape do |pot|
    if pot.shape.other?
      { name: I18n.t('shape.other') }
    else
      JSON.parse(
        ShapeBlueprint.render("Shape::#{pot.shape.capitalize}".constantize)
      )
    end
  end
end
