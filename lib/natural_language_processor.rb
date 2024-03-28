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
    now = DateTime.now
    text.gsub!(/午後|夕方|夜|深夜/, 'PM')
    text.gsub!(/午前|朝/, 'AM')
    DATE_TIME_MAPPINGS.each { |jp, en| text.gsub!(jp, en) }
    text.gsub!(/(\d+)月(\d+)日/, '\1/\2')
    text.gsub!(/(\d+)時/, '\1:')
    text.gsub!(/(\d+)分/, '\1')

    parsed_datetime = Chronic.parse(text)
    month, day, hour, minute = self.apply_defaults(parsed_datetime, now)
    final_datetime = DateTime.new(now.year, month, day, hour, minute)
    if final_datetime
      final_datetime.strftime('%Y-%m-%d %H:%M')
    else
      "日時情報を認識できませんでした"
    end
  end

  private

  def self.apply_defaults(parsed_datetime, now)
    month = parsed_datetime ? parsed_datetime.month : now.month
    day = if parsed_datetime
            parsed_datetime.day
          else
            now.day
          end
    hour = parsed_datetime&.hour || 9
    minute = parsed_datetime&.min || 0

    [month, day, hour, minute]
  end
end
