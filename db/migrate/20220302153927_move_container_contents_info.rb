class MoveContainerContentsInfo < ActiveRecord::Migration[5.2]
    def up
      execute "INSERT INTO container_contents (container_id, chemical_id, quantity, quantity_unit) SELECT id, chemical_id, container_size, size_unit FROM containers WHERE TRUE;"
    end
    def DOWN
      execute "UPDATE containers SET (chemical_id, container_size, size_unit) = (SELECT chemical_id, quantity, quantity_unit FROM container_contents WHERE container_contents.container_id = containers.id);"
      execute "DELETE FROM container_contents WHERE container_contents.container_id = containers.id;"
    end
  end
