# frozen_string_literal: true

class AddDistributions < ActiveRecord::Migration[7.2]
  def change
    create_table :distributions do |t|
      t.belongs_to :request_distribution, index: true
      t.belongs_to :bench, index: true
      t.belongs_to :pot, index: true

      t.integer :positions_on_bench, array: true
      t.integer :dimensions, array: true
      t.integer :seed_quantity

      t.timestamps
    end
  end
end
