# frozen_string_literal: true

class RemoveAttributeFromUsers < ActiveRecord::Migration[7.2]
  def change
    change_table :users, bulk: true do |t|
      t.remove :laboratory, :role, :type
    end
  end
end
