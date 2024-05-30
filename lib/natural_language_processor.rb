require 'active_support/all'
class NaturalLanguageProcessor
  DAY_MAPPINGS = {
    '月' => 0, '火' => 1, '水' => 2, '木' => 3,
    '金' => 4, '土' => 5, '日' => 6
  }.freeze

  ERA_START_YEARS = {
    '令和' => 2019
  }.freeze

  def self.full_to_half(text)
    text.tr('０-９', '0-9').tr('：', ':').tr('／', '/')
  end

  def self.parse_and_format_datetime(text)
    text = full_to_half(text)
    datetime = case text
               when /(今週|来週|再来週)[\s　の]*(日|月|火|水|木|金|土)(曜?日?)?/
                 day_match = text.match(/(今週|来週|再来週)[\s　の]*(日|月|火|水|木|金|土)(曜?日?)?/)
                 time_match = text.match(/[\s　の]*(\d{1,2})(?:時|:)(\d{1,2}|半)?分?/)
                 period_match = text.match(/(朝|午前|午後)/)
                 translate_weekday_and_relative_week(day_match, time_match, period_match)
               when /(今月|来月|再来月)[\s　の]*(\d{1,2})日[\s　の]*(朝|午前|午後)?(\d{1,2})?(?:時|:)?(\d{1,2}|半)?分?/
                 minutes = ::Regexp.last_match(5) == '半' ? 30 : ::Regexp.last_match(5).to_i
                 translate_month_relative_day_time(::Regexp.last_match(1), ::Regexp.last_match(2),
                                                   ::Regexp.last_match(3), ::Regexp.last_match(4), minutes)
               when /(今月|来月|再来月)[\s　の]*/
                 translate_month_relative_day_time(::Regexp.last_match(1), nil, nil, nil, nil)
               when /(今日|明日|明後日)[\s　の]*(朝|午前|午後)?(\d{1,2})?(?:時|:)?(\d{1,2}|半)?分?/
                 minutes = ::Regexp.last_match(4) == '半' ? 30 : ::Regexp.last_match(4)
                 translate_relative_day_time(::Regexp.last_match(1), ::Regexp.last_match(2), ::Regexp.last_match(3),
                                             minutes)
               when /来年[\s　の]*(\d+)月(\d+)日[\s　の]*(朝|午前|午後)?(\d{1,2})?(?:時|:)?(\d{1,2}|半)?分?/
                 parse_date_time_components(Time.current.year + 1, ::Regexp.last_match(1), ::Regexp.last_match(2),
                                            ::Regexp.last_match(3), ::Regexp.last_match(4), ::Regexp.last_match(5))
               when %r{来年[\s　の]*(\d+)/(\d+)[\s　の]*(朝|午前|午後)?(\d{1,2})?(?:時|:)?(\d{1,2}|半)?分?}
                 parse_date_time_components(Time.current.year + 1, ::Regexp.last_match(1), ::Regexp.last_match(2),
                                            ::Regexp.last_match(3), ::Regexp.last_match(4), ::Regexp.last_match(5))
               when /(\d{4})年[\s　の]*(\d+)月(\d+)日[\s　の]*(朝|午前|午後)?(\d{1,2})?(?:時|:)?(\d{1,2}|半)?分?/
                 parse_date_time_components(::Regexp.last_match(1), ::Regexp.last_match(2), ::Regexp.last_match(3),
                                            ::Regexp.last_match(4), ::Regexp.last_match(5), ::Regexp.last_match(6))
               when %r{(\d{4})年[\s　の]*(\d+)/(\d+)[\s　の]*(朝|午前|午後)?(\d{1,2})?(?:時|:)?(\d{1,2}|半)?分?}
                 parse_date_time_components(::Regexp.last_match(1), ::Regexp.last_match(2), ::Regexp.last_match(3),
                                            ::Regexp.last_match(4), ::Regexp.last_match(5), ::Regexp.last_match(6))
               when /(令和)(\d+)年[\s　の]*(\d+)月(\d+)日[\s　の]*(朝|午前|午後)?(\d{1,2})?(?:時|:)?(\d{1,2}|半)?分?/
                 year = ERA_START_YEARS[::Regexp.last_match(1)] + ::Regexp.last_match(2).to_i - 1
                 parse_date_time_components(year, ::Regexp.last_match(3), ::Regexp.last_match(4),
                                            ::Regexp.last_match(5), ::Regexp.last_match(6), ::Regexp.last_match(7))
               when %r{(令和)(\d+)年[\s　の]*(\d+)/(\d+)[\s　の]*(朝|午前|午後)?(\d{1,2})?(?:時|:)?(\d{1,2}|半)?分?}
                 year = ERA_START_YEARS[::Regexp.last_match(1)] + ::Regexp.last_match(2).to_i - 1
                 parse_date_time_components(year, ::Regexp.last_match(3), ::Regexp.last_match(4),
                                            ::Regexp.last_match(5), ::Regexp.last_match(6), ::Regexp.last_match(7))
               when /(\d{4})年[\s　の]*(\d+)月/
                 parse_date_time_components(::Regexp.last_match(1), ::Regexp.last_match(2), 1, nil, 6, 0)
               when /(令和)(\d+)年[\s　の]*(\d+)月/
                 year = ERA_START_YEARS[::Regexp.last_match(1)] + ::Regexp.last_match(2).to_i - 1
                 parse_date_time_components(year, ::Regexp.last_match(3), 1, nil, 6, 0)
               when /来年[\s　の]*(\d+)月/
                 parse_date_time_components(Time.current.year + 1, ::Regexp.last_match(1), 1, nil, 6, 0)
               when /来年/
                 parse_date_time_components(Time.current.year + 1, 1, 1, nil, 6, 0)
               when /(\d{4})年/
                 parse_date_time_components(::Regexp.last_match(1), 1, 1, nil, 6, 0)
               when /(令和)(\d+)年/
                 year = ERA_START_YEARS[::Regexp.last_match(1)] + ::Regexp.last_match(2).to_i - 1
                 parse_date_time_components(year, 1, 1, nil, 6, 0)
               when /(\d+)秒後|(\d+)分後|(\d+)時間後|(\d+)時間(\d+)分後|(\d+)時間半後|半日後|(\d+)日後|(\d+)週間後|(\d+)ヶ月後/
                 translate_relative_time(text)
               when /(\d{1,2})月(\d{1,2})日[\s　の]*(朝|午前|午後)?(\d{1,2})?(?:時|:)?(\d{1,2}|半)?分?/
                 minutes = ::Regexp.last_match(5) == '半' ? 30 : ::Regexp.last_match(5)
                 translate_specific_date_time(::Regexp.last_match(1), ::Regexp.last_match(2), ::Regexp.last_match(3),
                                              ::Regexp.last_match(4), minutes)
               when %r{(\d{1,2})/(\d{1,2})[\s　の]*(朝|午前|午後)?(\d{1,2})?(?:時|:)?(\d{1,2}|半)?分?}
                 minutes = ::Regexp.last_match(5) == '半' ? 30 : ::Regexp.last_match(5)
                 translate_specific_date_time(::Regexp.last_match(1), ::Regexp.last_match(2), ::Regexp.last_match(3),
                                              ::Regexp.last_match(4), minutes)
               when /(\d{1,2})月/
                 translate_specific_date_time(::Regexp.last_match(1), 1, nil, nil, nil)
               when /(\d{1,2})日[\s　の]*(朝|午前|午後)?(\d{1,2})?(?:時|:)?(\d{1,2}|半)?分?/
                 minutes = ::Regexp.last_match(4) == '半' ? 30 : ::Regexp.last_match(4)
                 translate_specific_date_time(nil, ::Regexp.last_match(1), ::Regexp.last_match(2),
                                              ::Regexp.last_match(3), minutes)
               when /(朝|午前|午後)?[\s　の]*(\d{1,2})(?:時|:)?(\d{1,2}|半)?分?/
                 minutes = ::Regexp.last_match(3) == '半' ? 30 : ::Regexp.last_match(3)
                 translate_specific_date_time(nil, nil, ::Regexp.last_match(1), ::Regexp.last_match(2), minutes)
               end
    datetime || 'Unrecognized format'
  end

  def self.format_datetime(datetime)
    datetime.strftime('%Y-%m-%d %H:%M:%S')
  end

  def self.translate_relative_day_time(day, period, hour, minutes)
    date = case day
           when '今日' then Time.current
           when '明日' then 1.day.since
           when '明後日' then 2.days.since
           else Time.current
           end

    hour = hour.nil? ? 6 : hour.to_i
    minutes = minutes.to_i

    hour = adjust_hour_for_period(hour.to_i, period)
    date = date.change(hour:, min: minutes)
    format_datetime(date)
  end

  def self.translate_specific_date_time(month, day, period, hour, minutes)
    current_time = Time.current

    year = current_time.year
    month = month.nil? ? current_time.month : month.to_i
    day = day.nil? ? current_time.day : day.to_i
    hour = hour.nil? ? 6 : hour.to_i
    minutes = minutes.to_i
    hour = adjust_hour_for_period(hour, period)
    date = Time.new(year, month, day, hour, minutes)
    format_datetime(date)
  end

  def self.translate_relative_time(text)
    case text
    when /(\d+)秒後/
      seconds = ::Regexp.last_match(1).to_i
      time = Time.current + seconds.seconds
    when /(\d+)分後/
      minutes = ::Regexp.last_match(1).to_i
      time = Time.current + minutes.minutes
    when /(\d+)分(\d+)秒後/
      minutes = ::Regexp.last_match(1).to_i
      seconds = ::Regexp.last_match(2).to_i
      time = Time.current + minutes.minutes + seconds.seconds
    when /(\d+)分半後/
      minutes = ::Regexp.last_match(1).to_i
      time = Time.current + minutes.minutes + 30.seconds
    when /(\d+)時間後/
      hours = ::Regexp.last_match(1).to_i
      time = Time.current + hours.hours
    when /(\d+)時間(\d+)分後/
      hours = ::Regexp.last_match(1).to_i
      minutes = ::Regexp.last_match(2).to_i
      time = Time.current + hours.hours + minutes.minutes
    when /(\d+)時間半後/
      hours = ::Regexp.last_match(1).to_i
      time = Time.current + hours.hours + 30.minutes
    when /半日後/
      time = Time.current + 12.hours
    when /(\d+)日後/
      days = ::Regexp.last_match(1).to_i
      time = Time.current + days.days
    when /(\d+)週間後/
      weeks = ::Regexp.last_match(1).to_i
      time = Time.current + weeks.weeks
    when /(\d+)ヶ月後/
      months = ::Regexp.last_match(1).to_i
      time = Time.current + months.months
    end
    format_datetime(time)
  end

  def self.translate_weekday_and_relative_week(day_match, time_match, period_match)
    week_modifier = case day_match[1]
                    when '今週' then 0.weeks
                    when '来週' then 1.week
                    when '再来週' then 2.weeks
                    end
    wday_key = day_match[2].gsub(/曜日?/, '')
    wday = DAY_MAPPINGS[wday_key]

    target_date = Time.current.beginning_of_week(:monday) + wday.days + week_modifier

    hour = time_match ? time_match[1].to_i : 6

    minute = time_match && time_match[2] ? time_match[2].to_i : 0
    minute = if time_match && time_match[2] == '半'
               30
             else
               (time_match && time_match[2] ? time_match[2].to_i : 0)
             end
    hour = adjust_hour_for_period(hour, period_match ? period_match[1] : nil)

    target_date = target_date.change(hour:, min: minute)
    format_datetime(target_date)
  end

  def self.translate_month_relative_day_time(month, day, period, hour, minutes)
    current_time = Time.current

    month_increment = case month
                      when '今月' then 0
                      when '来月' then 1
                      when '再来月' then 2
                      end
    target_time = current_time + month_increment.months

    day = day.nil? ? 1 : day.to_i
    hour = hour.nil? ? 6 : hour.to_i
    minutes = minutes.nil? ? 0 : minutes.to_i

    hour = adjust_hour_for_period(hour, period)

    datetime = Time.new(target_time.year, target_time.month, day, hour, minutes)
    format_datetime(datetime)
  end

  def self.parse_date_time_components(year, month, day, period, hour, minute)
    year = year.to_i
    month = month.to_i
    day ||= 1
    hour = if hour
             hour.to_i
           else
             (period == '午後' ? 12 : 6)
           end
    minute = minute == '半' ? 30 : (minute.to_i || 0)

    hour = adjust_hour_for_period(hour, period)
    date = Time.new(year, month, day, hour, minute)
    format_datetime(date)
  end

  def self.adjust_hour_for_period(hour, period)
    if period == '午後' && hour < 12
      hour + 12
    elsif %w[午前 朝].include?(period) && hour == 12
      0
    else
      hour
    end
  end
end
