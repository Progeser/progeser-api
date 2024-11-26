# frozen_string_literal: true

class RemoveColumnsFromRequestDistributions < ActiveRecord::Migration[7.2]
  def change
    change_table :request_distributions, bulk: true do |t|
      t.remove  :pot_id, type: :bigint
      t.remove  :pot_quantity, type: :integer
      t.remove  :area, type: :decimal
      t.remove  :bench_id, type: :bigint
    end
  end
end
