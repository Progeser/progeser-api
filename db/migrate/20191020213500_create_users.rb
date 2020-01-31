# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :encrypted_password, limit: 128, null: false
      t.string :confirmation_token, limit: 128
      t.string :remember_token, limit: 128, null: false

      t.string :role
      t.string :first_name
      t.string :last_name
      t.string :type
      t.string :laboratory

      t.timestamps
    end

    add_index :users, :email
    add_index :users, :remember_token
  end
end
