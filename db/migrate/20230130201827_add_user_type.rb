class AddUserType < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :type, :string, default: 'Buyer', null: false
  end
end
