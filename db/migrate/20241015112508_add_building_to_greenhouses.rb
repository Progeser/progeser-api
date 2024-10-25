# frozen_string_literal: true

class AddBuildingToGreenhouses < ActiveRecord::Migration[6.0]
  def change
    add_reference :greenhouses, :building, foreign_key: true

    reversible do |dir|
      dir.up do
        building = Building.create!(name: 'Default Building', location: 'Default Location')

        Greenhouse.find_each do |greenhouse|
          greenhouse.update!(building:)
        end
      end
    end
  end
end
