# frozen_string_literal: true

class RemoveShapeOnBenches < ActiveRecord::Migration[7.2]
  def up
    change_table :benches, bulk: true do |t|
      t.remove :shape, :area
    end
  end

  def down
    change_table :benches, bulk: true do |t|
      t.string :shape, null: false, default: 'rectangle'
      t.decimal :area, null: false, default: 0.0
    end
  end
end
