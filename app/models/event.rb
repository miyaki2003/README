class Event < ApplicationRecord
  belongs_to :user
  default_scope -> { order(start_time: :asc) }

  validates :title, presence: true
  validate  :start_end_check

  private

  def start_end_check
    return if start_time.blank? || end_time.blank?

    if start_time > end_time
      errors.add(:end_time, "が開始時刻を上回っています")
    end
  end
end