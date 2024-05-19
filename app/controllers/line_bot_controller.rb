class LineBotController < ApplicationController
  require 'line/bot'
  skip_before_action :verify_authenticity_token, only: [:callback]
  skip_before_action :require_login

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each do |event|
      case event.type
      when Line::Bot::Event::MessageType::Text
        handle_text_message(event)
      when Line::Bot::Event::MessageType::Location
        handle_location_message(event)
      end
    end
    
    head :ok
  end

  private

  def handle_text_message(event)
    user_id = event['source']['userId']
    user = User.find_or_create_by(line_user_id: user_id)
    user_message = event.message['text']
    case user_message
    when 'キャンセル'
      user.update(status: nil, temporary_data: nil)
      cancel_operation(event['replyToken'])
    when '一覧'
      send_reminder_list(user, event['replyToken'])
    when '今日'
      send_current_date_and_time(event['replyToken'])
    when '取り消し'
      cancel_last_reminder(user, event['replyToken'])
    when 'カレンダー'
      send_calendar_link(event['replyToken'])
    when '詳細'
      send_details_link(event['replyToken'])
    when '天気'
      send_weather_quick_reply(event['replyToken'])
    else
      if user.status == 'awaiting_time'
        process_user_message(user, user_message, event['replyToken'])
      else
        start_reminder_setting(user, user_message, event['replyToken'])
      end
    end
  end
  
  def start_reminder_setting(user, text, reply_token)
    user.update(status: 'awaiting_time', temporary_data: text)
    ask_for_time(reply_token)
  end

  def process_user_message(user, text, reply_token)
    parsed_datetime = parse_message(text)
    if parsed_datetime.nil?
      send_error_message(reply_token, "日時情報を正しく認識できませんでした\n再度日時を入力してください")
      user.update(status: 'awaiting_time')
    elsif Time.parse(parsed_datetime) <= Time.now
      send_error_message(reply_token, "過去の時間はリマインドできません\n再度日時を入力してください")
      user.update(status: 'awaiting_time')
    else
      set_and_confirm_reminder(user, user.temporary_data, Time.parse(parsed_datetime), reply_token)
      user.update(status: nil, temporary_data: nil)
    end
  end

  def set_and_confirm_reminder(user, title, reminder_time, reply_token)
    reminder = ReminderService.create(user: user, title: title, reminder_time: reminder_time)
    
    if reminder.persisted?
      confirm_reminder_set(reply_token, title, reminder.reminder_time)
    else
      send_error_message(reply_token, "リマインダーを設定できませんでした")
    end
  end

  def cancel_operation(reply_token)
    message = {
      type: 'text',
      text: '操作をキャンセルしました'
    }
    client.reply_message(reply_token, message)
  end
  
  def ask_for_time(reply_token)
    message = {
      type: 'text',
      text: 'いつリマインドしますか？'
    }
    client.reply_message(reply_token, message)
  end

  def confirm_reminder_set(reply_token, title, parsed_datetime)
    year = parsed_datetime.year
    month = parsed_datetime.month
    day = parsed_datetime.day
    hour = parsed_datetime.hour
    minute = parsed_datetime.min

    date_str = "#{year}年#{month}月#{day}日#{hour}時#{minute}分"


    message = {
      type: 'text',
      text: "#{date_str}に「#{title}」をリマインドします"
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

  def send_reminder_list(user, reply_token)
    reminders = user.reminders.where("is_active = ? AND reminder_time > ?", true, Time.now).order(reminder_time: :asc).limit(10)
    if reminders.empty?
        message_text = "リマインド一覧がありません"
    else
      message_text = "リマインド一覧です\n\n"
    
      reminders.each_with_index do |reminder, index|
        time = reminder.reminder_time
        message_text += "#{time.year}年#{time.month}月#{time.day}日#{time.hour}時#{time.min}分\n「#{reminder.title}」"
        message_text += "\n\n" unless index == reminders.size - 1
      end
    end
  
    message = {
      type: 'text',
      text: message_text
    }
    client.reply_message(reply_token, message)
  end

  def send_current_date_and_time(reply_token)
    wdays = ["日", "月", "火", "水", "木", "金", "土"]
    current_time = Time.current
    wday_num = current_time.wday

    year = current_time.year
    month = current_time.month
    day = current_time.day

    message_text = "今日は#{year}年#{month}月#{day}日#{wdays[wday_num]}曜日です"
    message = {
      type: 'text',
      text: message_text
    }
    client.reply_message(reply_token, message)
  end

  def cancel_last_reminder(user, reply_token)
    last_reminder = user.reminders.where(is_active: true).where("reminder_time > ?", Time.current).order(created_at: :desc).first
    if last_reminder
      reminder_title = last_reminder.title
      last_reminder.update(is_active: false)
      message = {
        type: 'text',
        text: "「#{reminder_title}」のリマインダーを取り消しました"
      }
    else
      message = {
        type: 'text',
        text: 'リマインダーが見つかりませんでした'
      }
    end
    client.reply_message(reply_token, message)
  end

  def send_calendar_link(reply_token)
    message = {
      type: 'text',
      text: 'カレンダーを見るには以下のボタンをタップしてください',
      quickReply: {
        items: [
          {
            type: 'action',
            action: {
              type: 'uri',
              label: 'カレンダーを開く',
              uri: 'https://liff.line.me/2003779201-OwqpG72P'
            }
          }
        ]
      }
    }
    client.reply_message(reply_token, message)
  end

  def send_details_link(reply_token)
    message = {
      type: 'text',
      text: '詳細を見るには以下のボタンをタップしてください',
      quickReply: {
        items: [
          {
            type: 'action',
            action: {
              type: 'uri',
              label: '詳細を開く',
              uri: 'https://liff.line.me/2003779201-yW3rm8DX'
            }
          }
        ]
      }
    }
    client.reply_message(reply_token, message)
  end

  def send_weather_quick_reply(reply_token)
    message = {
      type: 'text',
      text: '場所を選択してください',
      quickReply: {
        items: [
          {
            type: 'action',
            action: {
              type: 'location',
              label: '位置情報を指定'
            }
          }
        ]
      }
    }
    client.reply_message(reply_token, message)
  end

  def handle_location_message(event)
    Rails.logger.debug "handle_location_message called"
    user_id = event['source']['userId']
    user = User.find_or_create_by(line_user_id: user_id)
    latitude = event.message['latitude']
    longitude = event.message['longitude']
    Rails.logger.debug "Latitude: #{latitude}, Longitude: #{longitude}"
    weather_info = WeatherService.get_weather_info(latitude, longitude)
    Rails.logger.debug "Weather Info: #{weather_info}"
    if weather_info[:error]
      client.reply_message(event['replyToken'], { type: 'text', text: weather_info[:error] })
    else
      reply_weather_info(event['replyToken'], weather_info)
    end
  end

  def reply_weather_info(reply_token, weather_info)
    message = {
      type: 'flex',
      altText: '天気情報',
      contents: {
        type: 'bubble',
        body: {
          type: 'box',
          layout: 'vertical',
          contents: [
            {
              type: 'text',
              text: '現在の天気',
              weight: 'bold',
              size: 'lg'
            },
            {
              type: 'text',
              text: "天気: #{weather_info[:weather]}",
              size: 'md'
            },
            {
              type: 'text',
              text: "気温: #{weather_info[:temperature]}°C",
              size: 'md'
            },
            {
              type: 'text',
              text: "降水量: #{weather_info[:rainfall]} mm",
              size: 'md'
            }
          ]
        }
      }
    }
    client.reply_message(reply_token, message)
  end

  def parse_message(message)
    begin
      formatted_datetime = NaturalLanguageProcessor.parse_and_format_datetime(message)
      return nil if formatted_datetime.nil? || formatted_datetime.strip.empty?
      datetime = DateTime.parse(formatted_datetime)
      datetime.strftime('%Y-%m-%d %H:%M:%S')
    rescue ArgumentError
      nil
    end
  end

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_MESSAGING_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end