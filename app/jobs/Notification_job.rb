class NotificationJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    event = Event.find_by(id: event_id)
    return unless event

    client = Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }

    message = {
      type: 'text',
      text: "「#{event.title}」"
    }
    user_id = event.user.line_user_id

    response = client.push_message(line_user_id, message)
    puts response.body
  end
end