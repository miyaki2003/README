class AddImageUrlToReminders < ActiveRecord::Migration[7.1]
  def change
    add_column :reminders, :image_url, :string
  end
end
