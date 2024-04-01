require 'active_support/all'
class NaturalLanguageProcessor
  DAY_MAPPINGS = {
    "日" => 0, "月" => 1, "火" => 2, "水" => 3,
    "木" => 4, "金" => 5, "土" => 6
  }.freeze

  def self.full_to_half(text)
    text.tr('０-９', '0-9').tr('：', ':').tr('／', '/')
  end

  def self.parse_and_format_datetime(text)
    text = full_to_half(text)
    datetime = case text
               when /(今日|明日|明後日)の?(朝|午前|午後)?(\d{1,2})(?:時|:)(\d{1,2})?分?/#[\s　の]*をつける
                 translate_relative_day_time($1, $2, $3, $4)
                when /((\d{1,2})\/(\d{1,2})|(\d{1,2})月(\d{1,2})日)[\s　の]*(朝|午前|午後)?(\d{1,2})(?:時|:)(\d{1,2})?分?/
                 translate_specific_date_time($2 || $4, $3 || $5, $6, $7, $8 || 0)
               when /(\d{1,2})\/(\d{1,2})|(\d{1,2})月(\d{1,2})日/
                 translate_specific_date_time($1 || $3, $2 || $4, nil, 6, 0)
               when /((?:朝|午前|午後)?)(\d{1,2})(?:時|:)(\d{1,2})?分?/
                translate_time_with_default_date($1, $2, $3)
               when /(\d{1,2})月?/
                translate_month_only($1)
              when /(\d{1,2})日\s*(朝|午前|午後)?(\d{1,2})?時?(\d{1,2})?分?/
                translate_day_time($1, $2, $3, $4)
               when /(\d+)分後/, /(\d+)時間後/, /(\d+)日後/, /(\d+)週間後/, /(\d+)ヶ月後/
                translate_relative_time(text)
               else
                 day_match = text.match(/(今週|来週|再来週)の?(日|月|火|水|木|金|土)(曜?日?)?/)
                 time_match = text.match(/の?(\d{1,2})(?:時|:)(\d{1,2})?分?/)
                 period_match = text.match(/(朝|午前|午後)/)
                 translate_weekday_and_relative_week(day_match, time_match, period_match) if day_match
               end
    datetime || "Unrecognized format"
  end

  private

  def self.format_datetime(datetime)
    datetime.strftime('%Y-%m-%d at %H:%M')
  end

  def self.translate_relative_day_time(day, period, hour, minutes)
    date = case day
           when "今日" then Time.current
           when "明日" then 1.day.since
           when "明後日" then 2.days.since
           else Time.current
           end
    hour = hour ? hour : 6
    minutes = minutes ? minutes : 0
    hour = adjust_hour_for_period(hour, period)
    date = date.change(hour: hour, min: minutes)
    format_datetime(date)
  end

  def self.translate_specific_date_time(month, day, period, hour, minutes)
    year = Time.current.year
    hour = adjust_hour_for_period(hour, period)
    date = Time.new(year, month, day, hour, minutes)
    format_datetime(date)
  end

  def self.translate_time_with_default_date(period, hour, minutes)
    year = Time.current.year
    month = Time.current.month
    day = Time.current.day
    hour = adjust_hour_for_period(hour, period)
    date = Time.new(year, month, day, hour, minutes)
    format_datetime(date)
  end

  def self.translate_month_only(month)
    year = Time.current.year
    date = Time.new(year, month, 1, 6, 0)
    format_datetime(date)
  end

  def self.translate_day_time(day, period, hour, minutes)
    year = Time.current.year
    month = Time.current.month
    day = day.to_i
    hour = hour ? hour : 6
    minutes = minutes ? minutes : 0
    hour = adjust_hour_for_period(hour, period)
    date = Time.new(year, month, day, hour, minutes)
    format_datetime(date)
end
