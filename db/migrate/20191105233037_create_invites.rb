# frozen_string_literal: true

class CreateInvites < ActiveRecord::Migration[5.2]
  def change
    create_table :invites do |t|
      t.string :email, null: false
      t.string :invitation_token, null: false

      t.string :role
      t.string :first_name
      t.string :last_name
      t.string :laboratory

      t.timestamps
    end

    add_index :invites, :email, unique: true
    add_index :invites, :invitation_token, unique: true
  end
end
