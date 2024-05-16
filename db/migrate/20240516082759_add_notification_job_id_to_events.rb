class AddNotificationJobIdToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :notification_job_id, :string
  end
end
