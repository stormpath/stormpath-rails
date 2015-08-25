class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users  do |t|
      t.timestamps null: false
      t.string :email, null: false
      t.string :given_name, null: false
      t.string :surname, null: false
    end

    add_index :users, :email
  end
end
