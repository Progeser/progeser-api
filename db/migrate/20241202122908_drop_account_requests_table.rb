# frozen_string_literal: true

class DropAccountRequestsTable < ActiveRecord::Migration[7.2]
  def up
    drop_table :account_requests, if_exists: true
  end

  def down
    create_table :account_requests do |t|
      t.string :email, null: false
      t.string :first_name
      t.string :last_name
      t.text :comment
      t.string :laboratory
      t.boolean :accepted, default: false, null: false
      t.timestamps
    end

    add_index :account_requests, :email, unique: true
  end
end
