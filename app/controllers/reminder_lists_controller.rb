class ReminderListsController < ApplicationController
  def index
    @reminders = current_user.reminders.where("is_active = ? AND reminder_time > ?", true, Time.now).order(reminder_time: :asc)
  end

  def destroy
    @reminder = Reminder.find(params[:id])
    @reminder.update(is_active: false)
    redirect_to reminder_lists_path, notice: 'リマインドが削除されました'
  end
end
