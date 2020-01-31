# frozen_string_literal: true

class AddDimensionsToPots < ActiveRecord::Migration[6.0]
  def change
    add_column :pots, :dimensions, :integer, array: true
  end
end
