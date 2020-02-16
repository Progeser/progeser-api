# frozen_string_literal: true

class CreateRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :requests do |t|
      t.belongs_to :author, index: true
      t.belongs_to :handler, index: true
      t.belongs_to :plant_stage, index: true

      t.string :name
      t.string :plant_name
      t.string :stage_name
      t.string :status
      t.text :comment
      t.date :due_date
      t.integer :quantity
      t.integer :temperature
      t.integer :photoperiod

      t.timestamps
    end
  end
end
