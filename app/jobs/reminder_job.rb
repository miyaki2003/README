class ReminderJob < ApplicationJob
  queue_as :default

  def perform(reminder_id)
    reminder = Reminder.find_by(id: reminder_id, is_active: true)
    return unless reminder

    client = Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }

    message = {}  # 初期化しておくことでどの条件でも message が定義されていることを保証

    case reminder.reminder_type
    when 'text'
      # テキストの場合
      message = {
        type: 'text',
        text: "「#{reminder.title}」の時間です"
      }
    when 'image'
      # 画像の場合
      if reminder.image_id.present?
        message = {
          type: 'image',
          originalContentUrl: reminder.image_id,
          previewImageUrl: reminder.image_id
        }
      else
        # 画像URLが見つからない場合
        message = {
          type: 'text',
          text: "画像リマインダーのURLが見つかりませんでした"
        }
      end
    else
      # 未知のリマインダーの場合
      message = {
        type: 'text',
        text: "エラーが発生しました"
      }
    end

    # LINE APIを使ってメッセージを送信
    response = client.push_message(reminder.user.line_user_id, message)
  end
end