# frozen_string_literal: true

class UpdateRequestsTable < ActiveRecord::Migration[7.2]
  def up
    add_column :requests, :requester_first_name, :string, null: false, default: 'DefaultFirstName'
    add_column :requests, :requester_last_name, :string, null: false, default: 'DefaultLastName'
    add_column :requests, :requester_email, :string, null: false, default: 'default@example.com'
    add_column :requests, :laboratory, :string

    change_column_default :requests, :requester_first_name, nil
    change_column_default :requests, :requester_last_name, nil
    change_column_default :requests, :requester_email, nil

    remove_column :requests, :author_id, :bigint
  end

  def down
    remove_column :requests, :requester_first_name, :string
    remove_column :requests, :requester_last_name, :string
    remove_column :requests, :requester_email, :string
    remove_column :requests, :laboratory, :string

    add_column :requests, :author_id, :bigint
  end
end


