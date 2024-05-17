require 'sidekiq/api'
class NotificationJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    Rails.logger.info "Performing NotificationJob for event ID: #{event_id}"
    event = Event.find_by(id: event_id)
    return unless event && event.user.line_user_id.present?
    message_text = "「#{event.title}」のリマインドです"
    LineNotifyService.send_message(event.user.line_user_id, message_text)
    Rails.logger.info "LINE notification sent for event ID: #{event_id}"
  end
end