class Event < ApplicationRecord
  #belongs_to :user
  default_scope -> { order(start_time: :asc) }

  validates :title, presence: true
  validate  :start_end_check
  validate :notification_time_must_be_in_the_future, if: -> { line_notify && notify_time.present? }

  private

  def start_end_check
    return if start_time.blank? || end_time.blank?

    if start_time > end_time
      errors.add(:end_time, "が開始時刻を上回っています")
    end
  end

  def notification_time_must_be_in_the_future
    if notify_time < Time.current
      errors.add(:notify_time, 'は現在時刻よりも後の時間で設定してください。')
    end
  end
end