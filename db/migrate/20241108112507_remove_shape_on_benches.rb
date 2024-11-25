# frozen_string_literal: true

class RemoveShapeOnBenches < ActiveRecord::Migration[7.2]
  def change
    change_table :benches, bulk: true do |t|
      t.remove  :shape, type: :string, null: false, default: ''
      t.remove  :area, type: :decimal, null: false, default: 0.0
    end
  end
end
