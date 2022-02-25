class CreateContainerDescription < ActiveRecord::Migration[5.1]
  def change
    add_column :containers, :description, :string, null: true
  end
end
