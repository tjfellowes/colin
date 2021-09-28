class DeleteFulltextFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :chemicals, :name_fulltext
    remove_column :locations, :name_fulltext
  end
end
