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


  def self.handle_missing_information(input)
    month = input.match(/(\d+)月/)&.captures&.first.to_i || base_datetime.month
    day = input.match(/(\d+)日/)&.captures&.first.to_i || base_datetime.day
    hour = input.match(/(\d+)時/)&.captures&.first.to_i || 12
    minute = input.match(/(\d+)分/)&.captures&.first.to_i || 0

    year = base_datetime.year
    year += 1 if month < base_datetime.month

    DateTime.new(year, month, day, hour, minute)
  end

  def self.parse_and_format_datetime(input)
    input.gsub!(/午後|夕方|夜|深夜/, 'PM')
    input.gsub!(/午前|朝/, 'AM')
    input.gsub!(/(\d+)月(\d+)日/, '\1/\2')
    input.gsub!(/(\d+)時/, '\1:')
    input.gsub!(/(\d+)分/, '\1')
    DATE_TIME_MAPPINGS.each { |jp, en| input.gsub!(jp, en) }
    parsed_datetime = Chronic.parse(input)
    datetime_with_defaults = handle_missing_information(input, parsed_datetime || DateTime.now)
    datetime_with_defaults.strftime('%Y-%m-%d %H:%M')
  end
end
