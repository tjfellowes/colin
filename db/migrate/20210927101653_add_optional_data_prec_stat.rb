class AddOptionalDataPrecStat < ActiveRecord::Migration[5.2]
  def change
    create_table :chemical_prec_stat_supps do |t|
      t.references :chemical_prec_stat, index: true
      t.integer :position, null: false
      t.string :information, null: false
    end
  end
end
