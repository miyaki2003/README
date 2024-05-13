class ReminderService
  def self.create(user:, title: nil, reminder_time:, image_id: nil, reminder_type: 'text')

    if reminder_type == 'image' && image_id.nil?
      raise ArgumentError, "Image ID is required for image reminders"
    elsif reminder_type == 'text' && title.nil?
      raise ArgumentError, "Title is required for text reminders"
    end

    if reminder_type == 'image'
      reminder = user.reminders.build(image_id: image_id, reminder_time: reminder_time, reminder_type: reminder_type)
    else
      reminder = user.reminders.build(title: title, reminder_time: reminder_time, reminder_type: reminder_type)
    end
    
    if reminder.save
      ReminderJob.set(wait_until: reminder.reminder_time).perform_later(reminder.id)
    else
      Rails.logger.error("Failed to save reminder: #{reminder.errors.full_messages.join(", ")}")
      return nil
    end
    reminder
  end
end