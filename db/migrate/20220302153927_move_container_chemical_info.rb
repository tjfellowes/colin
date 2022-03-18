class MoveContainerChemicalInfo < ActiveRecord::Migration[5.2]
    def up
      execute "INSERT INTO container_chemicals (container_id, chemical_id, quantity, quantity_unit) SELECT id, chemical_id, container_size, size_unit FROM containers WHERE TRUE;"
    end
    def DOWN
      execute "UPDATE containers SET (chemical_id, container_size, size_unit) = (SELECT chemical_id, quantity, quantity_unit FROM container_chemicals WHERE container_chemicals.container_id = containers.id);"
      execute "DELETE FROM container_chemicals WHERE container_chemicals.container_id = containers.id;"
    end
  end
