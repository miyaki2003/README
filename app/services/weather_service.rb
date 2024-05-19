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
      lang: 'ja'
    })

    response = Net::HTTP.get(uri)
    data = JSON.parse(response)

    weather_description = data['weather'][0]['description']
    temperature = data['main']['temp']
    rainfall = data.dig('rain', '1h') || 0

    {
      weather: weather_description,
      temperature: temperature,
      rainfall: rainfall
    }
  end
end