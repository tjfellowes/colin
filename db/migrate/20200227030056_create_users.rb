class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.text        :username,      null: false
      t.text        :name,          null: false
      t.text        :email,          null: false
      t.text        :password_digest , null: false
      t.references  :supervisor,  references: :users
      t.boolean     :isadmin,       default: false
      t.boolean     :issuperuser,   default: false
      t.timestamps                  null: false
    end
  end
end
