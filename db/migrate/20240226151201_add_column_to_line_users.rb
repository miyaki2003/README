class AddColumnToLineUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :line_users, :provider, :string
    add_column :line_users, :uid, :string
    add_column :line_users, :name, :string, null:false
  end
end
