class ReminderJob < ApplicationJob
  queue_as :default

  def perform(reminder_id)
    reminder = Reminder.find_by(id: reminder_id, is_active: true)
    return unless reminder

    message = {
      type: 'text',
      text: "「#{reminder.title}」のリマインドです"
    }

    client = Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end

    response = client.push_message(reminder.user.line_user_id, message)
  end
end
