require 'net/http'
require 'uri'
require 'json'

class WeatherService
  API_URL = 'http://api.openweathermap.org/data/2.5/onecall'.freeze

  def self.get_weather_info(latitude, longitude)
    api_key = ENV['OPENWEATHERMAP_API_KEY']

    unless api_key
      puts "Error: OPENWEATHERMAP_API_KEY is not set."
      return { error: 'APIキーが設定されていません' }
    end

    puts "Using API Key: #{api_key}"

    uri = URI(API_URL)
    uri.query = URI.encode_www_form({
      lat: latitude,
      lon: longitude,
      appid: api_key,
      units: 'metric',
      lang: 'ja',
      exclude: 'minutely,daily'
    })

    begin
      response = Net::HTTP.get(uri)
      data = JSON.parse(response)

      puts "Request URL: #{uri}"
      puts "Response data: #{data}"

      if data['current'] && data['hourly']
        current_weather = {
          weather: data['current']['weather'][0]['description'],
          temperature: data['current']['temp'],
          rainfall: data['current'].dig('rain', '1h') || 0
        }

        forecasts = (1..4).map do |i|
          forecast_index = i * 3
          {
            weather: data['hourly'][forecast_index]['weather'][0]['description'],
            temperature: data['hourly'][forecast_index]['temp'],
            rainfall: data['hourly'][forecast_index].dig('rain', '3h') || 0
          }
        end

        {
          current: current_weather,
          forecasts: forecasts
        }
      else
        puts "Error: Unexpected data format: #{data}"
        { error: 'データを取得できませんでした' }
      end
    rescue => e
      puts "Error fetching weather data: #{e.message}"
      { error: 'データを取得できませんでした' }
    end
  end
end