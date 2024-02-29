class DeviseCreateLineUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :line_users do |t|
      t.string :line_user_id, null: false
      t.string :provider
      t.string :uid
      t.string :name, null:false
      t.timestamps null: false
    end

    add_index :line_users, [:uid, :provider], unique: true
  end
end
