# frozen_string_literal: true

class DropInvitesTable < ActiveRecord::Migration[7.2]
  def up
    drop_table :invites
  end

  def down
    create_table :invites do |t|
      t.string :email
      t.integer :sender_id
      t.integer :recipient_id
      t.string :token
      t.datetime :sent_at

      t.timestamps
    end
  end
end
