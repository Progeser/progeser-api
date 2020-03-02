# frozen_string_literal: true

class CreateRequestDistributions < ActiveRecord::Migration[6.0]
  def change
    create_table :request_distributions do |t|
      t.belongs_to :request, index: true
      t.belongs_to :bench, index: true
      t.belongs_to :plant_stage, index: true
      t.belongs_to :pot, index: true

      t.integer :pot_quantity
      t.decimal :area

      t.timestamps
    end
  end
end
