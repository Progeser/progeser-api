class AddSeedsLeftToPlantToRequestDistributions < ActiveRecord::Migration[7.2]
  def change
    add_column :request_distributions, :seeds_left_to_plant, :integer
  end
end
