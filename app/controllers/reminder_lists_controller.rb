class ReminderListsController < ApplicationController
  def index
    @reminders = Reminder.where(user_id: current_user.id, is_active: true).order(reminder_time: :asc)
  end

  def destroy
    @reminder = Reminder.find(params[:id])
    @reminder.update(is_active: false)
    redirect_to reminder_lists_path, notice: 'リマインドが削除されました'
  end
end
