def change
  remove_column :benches, :shape, :string, null: false
  remove_column :benches, :area, :decimal, null: false
end