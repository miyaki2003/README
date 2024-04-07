class RenameEndColumnToEndTimeInEvents < ActiveRecord::Migration[7.1]
  def change
    rename_column :events, :end, :end_time
  end
end
