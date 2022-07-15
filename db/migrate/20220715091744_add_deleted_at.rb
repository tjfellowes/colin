class AddDeletedAt < ActiveRecord::Migration[7.0]
  def change
    add_column :chemicals, :deleted_at, :datetime, index: true
    add_column :container_contents, :deleted_at, :datetime, index: true
    add_column :container_locations, :deleted_at, :datetime, index: true
    rename_column :containers, :date_disposed, :deleted_at
    add_index :containers, :deleted_at
    rename_column :locations, :date_deleted, :deleted_at
    add_index :locations, :deleted_at
    rename_column :suppliers, :date_deleted, :deleted_at
    add_index :suppliers, :deleted_at
    rename_column :users, :date_deleted, :deleted_at
    add_index :users, :deleted_at
  end
end
