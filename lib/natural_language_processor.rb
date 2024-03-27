require 'chronic'
require 'date'
require 'time'

class NaturalLanguageProcessor
  DATE_MAPPING = {
    '今日' => 'today',
    '明日' => 'tomorrow',
    '明後日' => 'day after tomorrow',
    '来週' => 'next week',
    '来月' => 'next month',
  }

  TIME_OF_DAY_MAPPING = {
    '午後' => 'PM',
    '夕方' => 'evening',
    '夜' => 'night',
    '深夜' => 'late night',
    '午前' => 'AM',
    '朝' => 'morning',
  }

  WEEKDAYS_MAPPING = {
    "日曜日" => "Sunday",
    "月曜日" => "Monday",
    "火曜日" => "Tuesday",
    "水曜日" => "Wednesday",
    "木曜日" => "Thursday",
    "金曜日" => "Friday",
    "土曜日" => "Saturday"
  }

  def self.apply_relative_time(text, base_time = DateTime.now)
    if match = text.match(/(\d+)(分後|時間後|日後|週間後|ヶ月後)/)
      amount = match[1].to_i
      case match[2]
      when "分後"
        base_time += Rational(amount, 1440)
      when "時間後"
        base_time += Rational(amount, 24)
      when "日後"
        base_time += amount
      when "週間後"
        base_time += amount * 7
      when "ヶ月後"
        base_time = (base_time.to_date >> amount).to_datetime
      end
    end
    base_time
  end

  def self.parse_datetime_with_defaults(input)
    now = DateTime.now
    month_match = input.match(/(\d+)月/)
    day_match = input.match(/(\d+)日/)
    hour_match = input.match(/(\d+)時/)
    minute_match = input.match(/(\d+)分/)

    month = month_match ? month_match[1].to_i : now.month
    day = if day_match
            day_match[1].to_i
          else
            
            month == now.month ? now.day : 1
          end
    hour = hour_match ? hour_match[1].to_i : 6 
    minute = minute_match ? minute_match[1].to_i : 0

    year = now.year
    if month < now.month
      year += 1
    end
    DateTime.new(year, month, day, hour, minute)
  end

  def self.parse_and_format_datetime(text)
    translated_text = translate_to_english(text)
    parsed_datetime = Chronic.parse(translated_text)
    datetime_with_defaults = parsed_datetime || parse_datetime_with_defaults(translated_text)
    final_datetime = apply_relative_time(text, datetime_with_defaults)
    final_datetime.strftime('%Y-%m-%d %H:%M')
  end

  def self.translate_to_english(text)
    [DATE_MAPPING, TIME_OF_DAY_MAPPING, WEEKDAYS_MAPPING].each do |mapping|
      text = mapping.reduce(text) do |t, (jp, en)|
        t.gsub(jp, en)
      end
    end
    text
  end
end
