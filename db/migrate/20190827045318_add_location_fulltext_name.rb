class AddLocationFulltextName < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :name_fulltext, :string, null: false, default: ''
  end
end
