class CreateStormpathRailsUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.timestamps null: false
      t.string :email, null: false
      t.string :given_name, null: false
      t.string :surname, null: false
    end

    add_index :users, :email
  end

  def self.down
    drop_table :users
  end
end