class ReminderService
  def self.create(user:, title:, reminder_time:)
    reminder = user.reminders.build(title:, reminder_time:)

    ReminderJob.set(wait_until: reminder.reminder_time).perform_later(reminder.id) if reminder.save
    reminder
  end
end
