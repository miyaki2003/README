class RemindersController < ApplicationController
  def index
    @reminders = Reminder.all.order(reminder_time: :asc)
  end
  def destroy
    @reminder = Reminder.find(params[:id])
    @reminder.destroy
    redirect_to reminders_path, notice: 'リマインダーが削除されました。'
  end

  private

  def set_reminder
    @reminder = Reminder.find(params[:id])
  end
end