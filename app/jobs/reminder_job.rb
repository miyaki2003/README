class ReminderJob < ApplicationJob
  queue_as :default

  def perform(reminder_id)
    reminder = Reminder.find_by(id: reminder_id, is_active: true)
    unless reminder
      Rails.logger.error("Reminder with ID #{reminder_id} not found or inactive.")
      return
    end

    client = Line::Bot::Client.new do |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    end

    message = prepare_message(reminder)
    response = client.push_message(reminder.user.line_user_id, message)
    if response.is_a?(Net::HTTPSuccess)
      Rails.logger.info("Message sent to #{reminder.user.line_user_id}: #{response.body}")
    else
      Rails.logger.error("Failed to send message: #{response.body}")
    end
  end

    private

  def prepare_message(reminder)
    case reminder.reminder_type
    when 'text'
      # テキストの場合
      { type: 'text', text: "「#{reminder.title}」の時間です" }
    when 'image'
      # 画像の場合
      if reminder.image_url.present?
        { type: 'image', originalContentUrl: reminder.image_url, previewImageUrl: reminder.image_url }
      else
        # 画像URLが見つからない場合
        { type: 'text', text: "画像リマインダーのURLが見つかりませんでした" }
      end
    else
      { type: 'text', text: "エラーが発生しました" }
    end
  end
end