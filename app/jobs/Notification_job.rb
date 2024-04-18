class NotificationJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    event = Event.find_by(id: event_id)
    return unless event && event.user && event.user.line_user_id.present?

    client = Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }

    message = {
      type: 'text',
      text: "「#{event.title}」"
    }

    line_user_id = event.user.line_user_id
    response = client.push_message(line_user_id, message)

    Rails.logger.info("Sending LINE message to user_id: #{line_user_id}")
  end
end