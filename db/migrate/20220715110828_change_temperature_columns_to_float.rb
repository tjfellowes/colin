class ChangeTemperatureColumnsToFloat < ActiveRecord::Migration[7.0]
  def up
    change_column :containers, :storage_temperature_min, :float, using: 'storage_temperature_min::double precision'
    change_column :containers, :storage_temperature_max, :float, using: 'storage_temperature_max::double precision'
    change_column :containers, :density, :float, using: 'density::double precision'
    change_column :containers, :melting_point, :float, using: 'melting_point::double precision'
    change_column :containers, :boiling_point, :float, using: 'boiling_point::double precision'
    change_column :chemicals, :storage_temperature_min, :float, using: 'storage_temperature_min::double precision'
    change_column :chemicals, :storage_temperature_max, :float, using: 'storage_temperature_max::double precision'
  end
  def down
    change_column :containers, :storage_temperature_min, :string, using: 'storage_temperature_min::double precision'
    change_column :containers, :storage_temperature_max, :string, using: 'storage_temperature_max::double precision'
    change_column :containers, :density, :string, using: 'density::double precision'
    change_column :containers, :melting_point, :string, using: 'melting_point::double precision'
    change_column :containers, :boiling_point, :string, using: 'boiling_point::double precision'
    change_column :chemicals, :storage_temperature_min, :string, using: 'storage_temperature_min::double precision'
    change_column :chemicals, :storage_temperature_max, :string, using: 'storage_temperature_max::double precision'
  end
end
