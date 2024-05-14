class NotificationJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    Rails.logger.info "Starting NotificationJob for event_id: #{event_id}"
    event = Event.find_by(id: event_id)
    if event.nil? || event.user.line_user_id.blank?
      Rails.logger.info "Event not found or line_user_id is missing."
      return
    end
    message_text = "「#{event.title}」のリマインドです"
    LineNotifyService.send_message(event.user.line_user_id, message_text)
    Rails.logger.info "Notification sent for event_id: #{event_id}"
  rescue StandardError => e
    Rails.logger.error "Error in NotificationJob for event_id: #{event_id}: #{e.message}"
  end
end