class AddLineUserIdToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :line_user_id, :string
  end
end
