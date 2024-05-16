require 'sidekiq/api'
class NotificationJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    event = Event.find_by(id: event_id)
    return unless event && event.user.line_user_id.present?
    message_text = "「#{event.title}」のリマインドです"
    Rails.logger.info "Sending LINE notification to #{event.user.line_user_id} with message: #{message_text}"
    LineNotifyService.send_message(event.user.line_user_id, message_text)
    Rails.logger.info "LINE notification sent"
  rescue => e
    Rails.logger.error "Failed to send LINE notification: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  def self.cancel(job_id)
    Rails.logger.info "Attempting to cancel job with ID: #{job_id}"
    job = Sidekiq::ScheduledSet.new.find_job(job_id)
    if job
      job.delete
      Rails.logger.info "Job with ID: #{job_id} cancelled successfully"
    else
      Rails.logger.info "Job with ID: #{job_id} not found"
    end
  end
end