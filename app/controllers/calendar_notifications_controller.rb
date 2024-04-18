class CalendarNotificationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    if valid_signature?
      enqueue_notifications
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

  def enqueue_notifications
    Event.where('notify_time <= ?', Time.current).each do |event|
      NotificationJob.perform_later(event.id) if event.line_notify && event.user.line_user_id.present?
    end
  end
end
