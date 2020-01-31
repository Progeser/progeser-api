# frozen_string_literal: true

class CreatePlants < ActiveRecord::Migration[6.0]
  def change
    create_table :plants do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
