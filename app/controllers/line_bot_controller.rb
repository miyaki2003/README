class LineBotController < ApplicationController
  require 'line/bot'
  skip_before_action :verify_authenticity_token, only: [:callback]

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      return head :bad_request
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
    user_message = line_event.message['text']
    response_message = "リマインドを設定します。内容と時間を入力してください"
    message = {
      type: 'text',
      text: response_message
    }
    client.reply_message(line_event['replyToken'], message)
  end
  
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_MESSAGING_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end