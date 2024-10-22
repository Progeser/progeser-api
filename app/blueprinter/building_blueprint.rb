# frozen_string_literal: true

class BuildingBlueprint < Base
  # Fields
  fields :name, :width, :height, :greenhouses

  field :occupancy do |building|
    building.greenhouses.sum(&:occupancy)
  end
end
