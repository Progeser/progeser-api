class AddBuildingToGreenhouses < ActiveRecord::Migration[6.0]
  def change
    add_reference :greenhouses, :building, foreign_key: true

    reversible do |dir|
      dir.up do
        building = Building.create!(name: 'Default Building', location: 'Default Location')

        Greenhouse.update_all(building_id: building.id)
      end
    end
  end
end

