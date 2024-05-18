class ReminderListsController < ApplicationController
  def index
    @reminders = current_user.reminders.where("is_active = ? AND reminder_time > ?", true, Time.now).order(reminder_time: :asc)
  end

  def deactivate
    @reminder = current_user.reminders.find(params[:id])
    if @reminder.update(is_active: false)
      redirect_to reminders_path
    else
      redirect_to reminders_path
    end
  end
end
