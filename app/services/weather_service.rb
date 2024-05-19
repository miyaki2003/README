require 'net/http'
require 'uri'
require 'json'

class WeatherService
  API_URL = 'http://api.openweathermap.org/data/2.5/weather'.freeze

  def self.get_weather_info(latitude, longitude)
    api_key = ENV['OPENWEATHERMAP_API_KEY']

    uri = URI(API_URL)
    uri.query = URI.encode_www_form({
      lat: latitude,
      lon: longitude,
      appid: api_key,
      units: 'metric',
      lang: 'ja',
    })

    response = Net::HTTP.get(uri)
    data = JSON.parse(response)

    current_weather = {
      weather: data['list'][0]['weather'][0]['description'],
      temperature: data['list'][0]['main']['temp'],
      rainfall: data['list'][0].dig('rain', '1h') || 0
    }

    forecasts = (1..6).map do |i|
      forecast_index = i * 2
      {
        weather: data['list'][i]['weather'][0]['description'],
        temperature: data['list'][i]['main']['temp'],
        rainfall: data['list'][i].dig('rain', '3h') || 0
      }
    end

    {
      current: current_weather,
      forecasts: forecasts
    }
  end
end