class ReminderListsController < ApplicationController
  def index
    @reminders = current_user.reminders.where("is_active = ? AND reminder_time > ?", true, Time.now).order(reminder_time: :asc)
  end

  # def deactivate
  #   @reminder = current_user.reminders.find(params[:id])
  #   if @reminder.update(is_active: false)
  #     redirect_to reminder_lists_path
  #   else
  #     redirect_to reminder_lists_path
  #   end
  # end

  def deactivate
    @reminder = current_user.reminders.find(params[:id])
    puts "Deactivating reminder with ID: #{params[:id]}"
    if @reminder.update(is_active: false)
      render json: { success: true }, status: :ok
    else
      render json: { success: true }, status: :ok
    end
  end
end
