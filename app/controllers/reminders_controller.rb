class RemindersController < ApplicationController
  def index
    @reminders = Reminder.order(:reminder_time).all
  end
  def destroy
    @reminder.destroy
    redirect_to reminders_url, notice: 'リマインドを削除しました。'
  end

  private

  def set_reminder
    @reminder = Reminder.find(params[:id])
  end
end