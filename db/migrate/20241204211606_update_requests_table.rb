# frozen_string_literal: true

class UpdateRequestsTable < ActiveRecord::Migration[7.2]
  def up
    change_table :requests, bulk: true do |t|
      t.string :requester_first_name, null: false, default: ''
      t.string :requester_last_name, null: false, default: ''
      t.string :requester_email, null: false, default: ''
      t.string :laboratory
      t.remove :author_id
    end
  end

  def down
    change_table :requests, bulk: true do |t|
      t.remove :requester_first_name
      t.remove :requester_last_name
      t.remove :requester_email
      t.remove :laboratory
      t.bigint :author_id
    end
  end
end
