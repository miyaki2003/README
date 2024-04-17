class CalendarNotificationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    if valid_signature?
      events = parse_events_from(request.body.read)
      events.each do |event|
        handle_event(event)
      end
      head :ok
    else
      head :bad_request
    end
  end

  private

  def valid_signature?
    client.validate_signature(request.body.read, request.env['HTTP_X_LINE_SIGNATURE'])
  end

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    }
  end

  def parse_events_from(body)
    client.parse_events_from(body)
  end

  def handle_event(event)
    case event
    when Line::Bot::Event::MessageType::Text
      process_text_message(event)
    end
  end

  def process_text_message(event)
  end
end
