require 'chronic'
require 'date'
require 'time'

class NaturalLanguageProcessor
  DATE_TIME_MAPPINGS = {
    '今日' => 'today',
    '明日' => 'tomorrow',
    '明後日' => 'day after tomorrow',
    '来週' => 'next week',
    '来月' => 'next month',
    '日曜日' => 'Sunday',
    '月曜日' => 'Monday',
    '火曜日' => 'Tuesday',
    '水曜日' => 'Wednesday',
    '木曜日' => 'Thursday',
    '金曜日' => 'Friday',
    '土曜日' => 'Saturday',
  }

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

  def self.format_text_for_chronic(text)
    formatted_text = text.dup
    DATE_TIME_MAPPINGS.each { |jp, en| formatted_text.gsub!(jp, en) }
    formatted_text.gsub!(/の/, '')
    formatted_text.gsub!(/(\d+)月(\d+)日/, '\1/\2')
    formatted_text.gsub!(/(\d+)時/, '\1:')
    formatted_text.gsub!(/(\d+)分/, '\1')
    formatted_text.gsub!(/午後|夕方|夜/, 'pm')
    formatted_text.gsub!(/午前|朝/, 'am')
    formatted_text
  end

  def self.apply_defaults(parsed_datetime)
    default_hour = 9
    default_minute = 0

    year = parsed_datetime ? parsed_datetime.year : now.year
    month = parsed_datetime ? parsed_datetime.month : now.month
    day = if parsed_datetime
      parsed_datetime.day
    else
      if month == now.month
        now.day
      else
        1
      end
    end
    hour = parsed_datetime.hour || default_hour
    minute = parsed_datetime.min || default_minute
    Time.zone.local(year, month, day, hour, minute)
  end

  def self.parse_time_from_text(text)
    formatted_text = format_text_for_chronic(text)
    parsed_datetime = Chronic.parse(formatted_text)
    if parsed_datetime
      final_datetime = apply_defaults(parsed_datetime)
      final_datetime.strftime('%Y-%m-%d %H:%M')
    else
      nil
    end
  end
end
