class AddMemoToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :memo, :text
  end
end
