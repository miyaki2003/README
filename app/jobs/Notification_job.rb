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

  def self.cancel(job_id, event_id)

    event = Event.find_by(id: event_id)
    unless event
      Rails.logger.error "イベントが見つかりませんでした: #{event_id}"
      return
    end

    Rails.logger.info "データベースのジョブID: #{event.notification_job_id}, 渡されたジョブID: #{job_id}"

    if event.notification_job_id != job_id
      Rails.logger.error "データベースのジョブIDと渡されたジョブIDが一致しません: #{event.notification_job_id} != #{job_id}"
      return
    end

    scheduled_set = Sidekiq::ScheduledSet.new
    Rails.logger.info "Scheduled jobs in Sidekiq:"
    scheduled_set.each do |job|
      enqueued_at = job.enqueued_at ? Time.at(job.enqueued_at) : 'nil'
      Rails.logger.info "Job ID: #{job.jid}, Class: #{job.klass}, Args: #{job.args}, Enqueued At: #{enqueued_at}"
    end
    
    job = scheduled_set.find { |j| j.jid == job_id }
    Rails.logger.info "取得したジョブ: #{job.inspect}"

    unless job
      Rails.logger.error "ジョブが見つかりませんでした"
      return
    end

    job.delete
    Rails.logger.info "ジョブがキャンセルされました: #{job_id}"
  end
end