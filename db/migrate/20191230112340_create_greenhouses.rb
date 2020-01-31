# frozen_string_literal: true

class CreateGreenhouses < ActiveRecord::Migration[6.0]
  def change
    create_table :greenhouses do |t|
      t.string :name, null: false
      t.integer :width, null: false
      t.integer :height, null: false
      t.decimal :occupancy, null: false, default: 0

      t.timestamps
    end
  end
end
