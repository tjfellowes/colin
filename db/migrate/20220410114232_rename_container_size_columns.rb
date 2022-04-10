class RenameContainerSizeColumns < ActiveRecord::Migration[5.2]
  def change
    rename_column :containers, :container_size, :container_size_number
    rename_column :containers, :size_unit, :container_size_unit
  end
end
