class AddImageIdAndReminderTypeToReminders < ActiveRecord::Migration[7.1]
  def change
    add_column :reminders, :image_id, :string
    add_column :reminders, :reminder_type, :string, default: 'text'
  end
end
