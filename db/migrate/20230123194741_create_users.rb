class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :username, null: false, unique: true
      t.string :password, null: false
      t.integer :deposit, default: 0
      t.integer :role, default: 0, null: false

      t.timestamps
    end
  end
end
