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

  def self.cancel(job_id)
    Rails.logger.info "Attempting to cancel job with ID: #{job_id}"
    scheduled_set = Sidekiq::ScheduledSet.new
    scheduled_set.each do |job|
      Rails.logger.info "Job ID: #{job.jid}, Class: #{job.klass}, Args: #{job.args}, At: #{Time.at(job.at)}"
    end
    job = scheduled_set.find { |j| j.jid == job_id }
    if job
      job.delete
      Rails.logger.info "Job with ID: #{job_id} cancelled"
    else
      Rails.logger.info "Job with ID: #{job_id} not found in ScheduledSet"
    end
  end
end