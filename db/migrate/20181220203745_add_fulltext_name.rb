class AddFulltextName < ActiveRecord::Migration[5.1]
  def change
    add_column :chemicals, :name_fulltext, :string, null: false, default: ''
  end
end
