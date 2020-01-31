# frozen_string_literal: true

class CreatePlantStages < ActiveRecord::Migration[6.0]
  def change
    create_table :plant_stages do |t|
      t.string :name, null: false
      t.integer :duration
      t.integer :position, null: false

      t.belongs_to :plant, index: true

      t.timestamps
    end
  end
end
