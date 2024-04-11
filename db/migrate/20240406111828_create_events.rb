class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :title
      t.datetime :start_time
      t.datetime :end_time
      t.datetime :notify_time
      t.boolean :line_notify, default: false

      t.timestamps
    end
  end
end
