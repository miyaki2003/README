require 'net/http'
require 'uri'
require 'json'
require 'chronic'

class NaturalLanguageProcessor
  def self.translate_japanese_to_english(text)
    if text =~ /今日の(\d+)時(\d*)分?/
      hour = $1.to_i
      minutes = $2.empty? ? '00' : $2
      "today at #{format('%02d', hour)}:#{minutes}"
    elsif text =~ /明日の(\d+)時(\d*)分?/
      hour = $1.to_i
      minutes = $2.empty? ? '00' : $2
      "tomorrow at #{format('%02d', hour)}:#{minutes}"
    elsif text =~ /午前(\d+)時(\d*)分?/
      hour = $1.to_i
      minutes = $2.empty? ? '00' : $2
      "#{format('%02d', hour)}:#{minutes} AM"
    elsif text =~ /午後(\d+)時(\d*)分?/
      hour = $1.to_i == 12 ? 12 : $1.to_i + 12
      minutes = $2.empty? ? '00' : $2
      "#{format('%02d', hour)}:#{minutes} PM"
    else
      case text
      when "今日"
        "today"
      when "明日"
        "tomorrow"
      else
        text
      end
    end
  end

  def self.parse_time_from_text(text)
    translated_text = translate_japanese_to_english(text)
    datetime = Chronic.parse(translated_text)
    
    if datetime
      datetime.strftime('%Y-%m-%d %H:%M:%S')
    else
      nil
    end
  end
end
