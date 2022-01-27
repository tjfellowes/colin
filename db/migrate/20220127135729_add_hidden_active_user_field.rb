class AddHiddenActiveUserField < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :active, :boolean, default: true
    add_column :users, :hidden, :boolean, default: false
  end
end
