class CreateStormpathRailsUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email, null: false
      t.string :username
      t.string :given_name
      t.string :surname
      t.timestamps null: false
    end

    add_index :users, :email
  end

  def self.down
    drop_table :users
  end
end
