# frozen_string_literal: true

class CreateBuildings < ActiveRecord::Migration[7.2]
  def change
    create_table :buildings do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
