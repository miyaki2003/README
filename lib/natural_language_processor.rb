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

  def self.parse_time_from_text(text)
    now = Time.zone.now
    
    formatted_text = format_text_for_chronic(text)
    
    parsed_datetime = Chronic.parse(formatted_text)

    if parsed_datetime
      datetime_with_defaults = apply_defaults(parsed_datetime, now)
      datetime_with_defaults.strftime('%Y-%m-%d %H:%M')
    else
      nil
    end
  end

  private

  def self.format_text_for_chronic(text)
    formatted_text = text.dup
    formatted_text.gsub!(/午後|夕方|夜|深夜/, 'PM')
    formatted_text.gsub!(/午前|朝/, 'AM')
    DATE_TIME_MAPPINGS.each { |jp, en| formatted_text.gsub!(jp, en) }
    formatted_text.gsub!(/(\d+)月(\d+)日/, '\1/\2')
    formatted_text.gsub!(/(\d+)時/, '\1:')
    formatted_text.gsub!(/(\d+)分/, '\1')
    formatted_text
  end

  def self.apply_defaults(parsed_datetime, now)
   
    year = parsed_datetime.year
    month = parsed_datetime.month
    day = parsed_datetime.day
    hour = parsed_datetime.hour || 9
    minute = parsed_datetime.min || 0

  
    Time.zone.local(year, month, day, hour, minute)
  end
end