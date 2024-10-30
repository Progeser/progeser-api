# frozen_string_literal: true

class AddBuildingToGreenhouses < ActiveRecord::Migration[7.2]
  def up
    add_reference :greenhouses, :building, foreign_key: true

    building = Building.create!(name: 'Default Building', description: 'Default Location')
    Greenhouse.find_each do |greenhouse|
      greenhouse.update!(building:)
    end
  end

  def down
    remove_reference :greenhouses, :building, foreign_key: true
  end
end
