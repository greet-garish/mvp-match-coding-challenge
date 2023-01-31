class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.integer :amount, default: 0
      t.string :name, null: false
      t.integer :cost, default: 0
      t.references :seller, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
