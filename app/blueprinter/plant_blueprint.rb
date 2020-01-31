# frozen_string_literal: true

class PlantBlueprint < Base
  # Fields
  fields :name

  # Associations
  association :plant_stages, blueprint: PlantStageBlueprint
end
