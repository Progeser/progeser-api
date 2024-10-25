# frozen_string_literal: true

class ModifyBuildingModel < ActiveRecord::Migration[6.0]
  def change
    change_table :buildings, :location

    add_column :buildings, :description, :text
  end
end
