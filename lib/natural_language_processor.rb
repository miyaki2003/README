require 'net/http'
require 'uri'
require 'json'
require 'chronic'
require 'date'
require 'time'

class NaturalLanguageProcessor
  def self.parse_and_format_datetime(text)
    case text
    when /(今日|明日|明後日)の?(朝|午前|午後)?(\d+)(?:時|:)(\d*)分?/
      translate_relative_day_time($1, $2, $3, $4)
    when /(\d+)月(\d+)日の?(朝|午前|夜|午後)?(\d+)(?:時|:)(\d*)分?/
      translate_specific_date_time($1, $2, $3, $4, $5)
    when /(\d+)分後/, /(\d+)時間後/, /(\d+)日後/, /(\d+)週間後/, /(\d+)ヶ月後/
      translate_relative_time(text)
    else
      translate_weekday_and_relative_week(text)
    end
  end
  
  private

  def self.translate_relative_day_time(day, period, hour, minutes)
    date = case day
           when "今日" then Date.today
           when "明日" then Date.today + 1
           when "明後日" then Date.today + 2
           else Date.today
           end
    hour = adjust_hour_for_period(hour.to_i, period)
    "#{date} at #{format('%02d', hour)}:#{format('%02d', minutes.to_i)}"
  end

  def self.translate_specific_date_time(month, day, period, hour, minutes)
    year = Date.today.year
    hour = adjust_hour_for_period(hour.to_i, period)
    "#{year}-#{format('%02d', month)}-#{format('%02d', day)} at #{format('%02d', hour)}:#{format('%02d', minutes.to_i)}"
  end

  def self.adjust_hour_for_period(hour, period)
    return hour if period.nil?
    if period == "午後" && hour < 12
      hour + 12
    elsif (period == "午前" || period == "朝") && hour == 12
      0
    else
      hour
    end
  end

  def self.translate_relative_time(text)
    case text
    when /(\d+)分後/
      minutes = $1.to_i
      time = Time.now + (minutes * 60)
    when /(\d+)時間後/
      time = Time.now + (60 * 60)
    when /(\d+)日後/
      time = Time.now + (24 * 60 * 60)
    when /(\d+)週間後/
      time = Time.now + (7 * 24 * 60 * 60)
    when /(\d+)ヶ月後/
      time = Time.now + (30 * 24 * 60 * 60)
    else
      return "Unrecognized format"
    end
    time.strftime('%Y-%m-%d %H:%M:%S')
  end

  def self.translate_weekday_and_relative_week(text)
    day_english = {
      /日曜?日?/ => "Sunday",
      /月曜?日?/ => "Monday",
      /火曜?日?/ => "Tuesday",
      /水曜?日?/ => "Wednesday",
      /木曜?日?/ => "Thursday",
      /金曜?日?/ => "Friday",
      /土曜?日?/ => "Saturday"
    }
    
    #case text
    #when /(今週)の?(.+)/
    #  day = day_english[$1]
    #  "this #{day}"
    #when /来週の?(.+)/
    #  day = day_english[$1]
    #  "next #{day}"
    #when /再来週の?(.+)/
    #  day = day_english[$1]
    #  "#{day} in two weeks"
    #else
    #  "Unrecognized format"
    #end

    time_match = text.match(/(\d+)(?:時|:)(\d*)分?/)
    hour = time_match ? time_match[1].to_i : 6
    minute = time_match && !time_match[2].empty? ? time_match[2].to_i : 0

    period_match = text.match(/(朝|午前|午後)/)
    period = period_match ? period_match[1] : nil

    if period == "午後" && hour < 12
      hour += 12
    elsif (period == "朝" || period == "午前") && hour == 12
      hour = 0
    end

    text.gsub!(/(今週|来週|再来週)の?(朝|午前|午後)?(.+)/) do |match|
      period_keyword, time_of_day, day_japanese = $1, $2, $3
      day_english_value = day_english.find { |k, _| day_japanese =~ k }.last
      period_english = case period_keyword
                        when "今週" then "this"
                        when "来週" then "next"
                        when "再来週" then "in two weeks"
                        end
      formatted_hour = format('%02d', hour)
      formatted_minute = format('%02d', minute)
      "#{period_english} #{day_english_value} #{formatted_hour}:#{formatted_minute}"
    end
  end

  def self.parse_time_from_text(text)
    translated_text = parse_and_format_datetime(text)
    datetime = Chronic.parse(translated_text)
    if datetime
      datetime.strftime('%Y-%m-%d %H:%M')
    else
      nil
    end
  end
end
