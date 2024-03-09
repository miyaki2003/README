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
        user_message = event.message['text']
        reply_text = ""
    
        Rails.logger.info "Received message: #{user_message}"
    
        if user_message == "会議"
          reply_text = "いつリマインドしますか？"
          Rails.logger.info "Replying with: #{reply_text}" 
        elsif user_message.match?(/^\d+時$/)
          reply_text = "#{user_message}に会議のリマインドを設定しました"
          Rails.logger.info "Replying with: #{reply_text}" 
        else
          
          reply_text = "ごめんなさい、理解できませんでした。"
          Rails.logger.info "Replying with: #{reply_text}"
        end
    
        message = {
          type: 'text',
          text: reply_text
        }
        client.reply_message(event['replyToken'], message)
      end
    end    

    head :ok
  end
  private

  def client
    @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_MESSAGING_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end
