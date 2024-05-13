class NotificationJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    event = Event.find_by(id: event_id)
    return unless event && event.user.line_user_id.present?

    event.reload

    message_text = "「#{event.title}」のリマインドです"
    LineNotifyService.send_message(event.user.line_user_id, message_text)
  end
end