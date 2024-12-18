# frozen_string_literal: true

class ChangeTemperatureToEnumInRequests < ActiveRecord::Migration[7.2]
  def up
    change_column :requests, :temperature, :string
  end

  def down
    change_column :requests, :temperature, :integer
  end
end
