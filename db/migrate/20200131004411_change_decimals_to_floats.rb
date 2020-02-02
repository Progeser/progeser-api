# frozen_string_literal: true

class ChangeDecimalsToFloats < ActiveRecord::Migration[6.0]
  def up
    change_column :greenhouses, :occupancy, :float
    change_column :benches, :area, :float
    change_column :pots, :area, :float
  end

  def down
    change_column :greenhouses, :occupancy, :decimal
    change_column :benches, :area, :decimal
    change_column :pots, :area, :decimal
  end
end
