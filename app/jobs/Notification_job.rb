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
    Rails.logger.info "Attempting to cancel job with ID: #{job_id} at #{Time.now}"
    
    sets = [Sidekiq::ScheduledSet.new, Sidekiq::RetrySet.new, Sidekiq::Queue.new, Sidekiq::DeadSet.new]
    
    sets.each do |set|
      set.each do |job|
        Rails.logger.info "Checking job with ID: #{job.jid} in #{set.class.name} at #{Time.now}"
      end
      job = set.find { |j| j.jid == job_id }
      if job
        job.delete
        Rails.logger.info "Job with ID: #{job_id} cancelled from #{set.class.name} at #{Time.now}"
        return true
      end
    end

    Rails.logger.info "Job with ID: #{job_id} not found in any set at #{Time.now}"
    false
  end
end