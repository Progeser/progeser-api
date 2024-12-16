# frozen_string_literal: true

class RemoveAttributeFromUsers < ActiveRecord::Migration[7.2]
  def up
    change_table :users, bulk: true do |t|
      t.remove :laboratory, :role, :type
    end
  end

  def down
    change_table :users, bulk: true do |t|
      t.string :laboratory
      t.string :role
      t.string :type
    end
  end
end
