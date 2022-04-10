class RenameChemicalJoinTables < ActiveRecord::Migration[5.2]
  def change
    rename_table :chemical_haz_stats, :chemicals_haz_stats
    rename_table :chemical_prec_stats, :chemicals_prec_stats
    rename_table :chemical_haz_classes, :chemicals_haz_classes
    rename_table :chemical_pictograms, :chemicals_pictograms
  end
end
