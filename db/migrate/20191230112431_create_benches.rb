# frozen_string_literal: true

class CreateBenches < ActiveRecord::Migration[6.0]
  def change
    create_table :benches do |t|
      t.belongs_to :greenhouse, index: true

      t.string :name
      t.string :shape, null: false
      t.decimal :area, null: false
      t.integer :dimensions, array: true

      t.timestamps
    end
  end
end
