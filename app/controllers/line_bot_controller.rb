class LineBotController < ApplicationController
  require 'line/bot'
  skip_before_action :verify_authenticity_token, only: [:callback]

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each do |event|
      if event.type == Line::Bot::Event::MessageType::Text
        handle_text_message(event)
      end
    end

    head :ok
  end

  private

  def handle_text_message(line_event)
    user_id = line_event['source']['userId']
    user = User.find_or_create_by(line_user_id: user_id)
    user_message = line_event.message['text']

    if user_message.downcase == 'キャンセル'
      cancel_operation(user, line_event['replyToken'])
    else
      process_user_message(user, text, line_event['replyToken'])
    end
  end

  def process_user_message(user, text, reply_token)
    case user.status
    when nil, '', 'awaiting_title'
      #ユーザーがタイトルを送信
      set_user_status(user, 'awaiting_time', text)
      ask_for_time(reply_token)
    when 'awaiting_time'
      #ユーザーが時間を送信
      set_and_confirm_reminder(user, text, reply_token)
    end
  end

  def set_and_confirm_reminder(user, time_text, reply_token)
    reminder_time = parse_datetime(time_text)

    if reminder_time
      user.reminders.create(title: user.temporary_data, reminder_time: reminder_time)
      confirm_reminder_set(reply_token, user.temporary_data, reminder_time)
      clear_user_status(user)
    else
      send_error_message(reply_token, "日時情報を正しく認識できませんでした")
    end
  end

  def cancel_operation(reply_token)
    message = {
      type: 'text',
      text: '操作をキャンセルしました。'
    }
    client.reply_message(reply_token, message)
  end
  





  

  def process_datetime_input(user, time_text, line_event)
    parsed_datetime_str = NaturalLanguageProcessor.parse_time_from_text(time_text)
  
    if parsed_datetime_str.present?
      parsed_datetime = Time.zone.parse(parsed_datetime_str)

      create_and_confirm_reminder(user, get_temporary_data(user), parsed_datetime, line_event['replyToken'])
    else
      send_error_message(line_event['replyToken'], "日時情報を正しく認識できませんでした。もう一度入力してください。")
    end
  end

  if parsed_datetime_str.present?
    parsed_datetime = Time.zone.parse(parsed_datetime_str)
    title = "リマインダーのタイトル"
    return [title, parsed_datetime]
  else
    return [nil, nil]
  end


  





  def ask_for_time(reply_token)
    message = {
      type: 'text',
      text: 'いつリマインドしますか？'
    }
    client.reply_message(reply_token, message)
  end

  def confirm_reminder_set(reply_token, title, parsed_datetime)
    message = {
      type: 'text',
      text: "#{parsed_datetime.strftime('%Y年%m月%d日%H時%M分')}に「#{title}」をリマインドします"
    }
    client.reply_message(reply_token, message)
  end

  def send_error_message(reply_token, message_text)
    message = {
      type: 'text',
      text: message_text
    }
    client.reply_message(reply_token, message)
  end

  def parse_message(message)
    parsed_datetime_str = NaturalLanguageProcessor.parse_time_from_text(message)
    if parsed_datetime_str.present?
      parsed_datetime = Time.zone.parse(parsed_datetime_str)

      title = extract_title_from_message(message)
      return [title, parsed_datetime]
    else
      return [nil, nil]
    end
  end

  def extract_title_from_message(message)
    message
  end


  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_MESSAGING_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end