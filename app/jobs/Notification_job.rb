require 'sidekiq/api'
class NotificationJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    event = Event.find_by(id: event_id)
    return unless event && event.user.line_user_id.present?
    message_text = "「#{event.title}」のリマインドです"
    LineNotifyService.send_message(event.user.line_user_id, message_text)
    Rails.logger.info "NotificationJob executed at: #{Time.now}"
    Rails.logger.info "NotificationJob: event_id=#{event_id}, user=#{event.user.id}, line_user_id=#{event.user.line_user_id}"
  end

  def self.cancel(job_id)
    scheduled_set = Sidekiq::ScheduledSet.new
    job = scheduled_set.find { |j| j.args.any? { |arg| arg["job_id"] == job_id } }
    if job
      job.delete
    end
  end  
end