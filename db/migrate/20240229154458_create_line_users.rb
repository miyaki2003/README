class CreateLineUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :line_users do |t|
      t.string :provider
      t.string :uid
      t.string :name

      t.timestamps
    end
    add_index :line_users, [:uid, :provider], unique: true
  end
end
