class CreatePots < ActiveRecord::Migration[6.0]
  def change
    create_table :pots do |t|
      t.string :name, null: false
      t.string :shape, null: false
      t.decimal :area, null: false

      t.timestamps
    end
  end
end
