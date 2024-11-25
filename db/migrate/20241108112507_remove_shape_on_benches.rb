# frozen_string_literal: true

class RemoveShapeOnBenches < ActiveRecord::Migration[7.2]
  def change
    change_table :benches, bulk: true do |t|
      t.remove :benches, :shape, type: :string, null: false, default: ''
      t.remove :benches, :area, type: :decimal, null: false
    end
  end
end
