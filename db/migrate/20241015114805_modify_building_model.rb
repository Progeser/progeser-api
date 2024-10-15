class ModifyBuildingModel < ActiveRecord::Migration[6.0]
  def change
    remove_column :buildings, :location, :string

    add_column :buildings, :description, :text
  end
end

