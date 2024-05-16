require 'sidekiq/api'
class NotificationJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    event = Event.find_by(id: event_id)
    return unless event && event.user.line_user_id.present?
    message_text = "「#{event.title}」のリマインドです"
    LineNotifyService.send_message(event.user.line_user_id, message_text)
  end

  def self.cancel(job_id)
    scheduled_set = Sidekiq::ScheduledSet.new
    job = scheduled_set.find { |j| j.jid == job_id }
    if job
      job.delete
    else
    end
  end
end