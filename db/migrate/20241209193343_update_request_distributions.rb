# frozen_string_literal: true

class UpdateRequestDistributions < ActiveRecord::Migration[7.2]
  def change
    change_table :request_distributions, bulk: true do |t|
      t.remove :area, type: :decimal
      t.integer :positions_on_bench, array: true
      t.integer :dimensions, array: true
    end
  end
end
