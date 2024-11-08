class AddPositionsToBenches < ActiveRecord::Migration[7.2]
  def change
    add_column :benches, :positions, :integer, array: true
  end
end
