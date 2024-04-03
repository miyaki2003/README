class AddIsActiveToReminders < ActiveRecord::Migration[7.1]
  def change
    add_column :reminders, :is_active, :boolean, default: true, null: false
  end
end
