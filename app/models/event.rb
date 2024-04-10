class Event < ApplicationRecord
  belongs_to :user
  default_scope -> { order(start: :asc) }

  validates :title, presence: true
  validate  :start_end_check

  private

  def start_end_check
    return if start.blank? || end_time.blank?

    if start > end_time
      errors.add(:end_time, "が開始時刻を上回っています。正しく記入してください。")
    end
  end
end