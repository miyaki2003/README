require 'net/http'
require 'uri'
require 'json'

class NaturalLanguageProcessor
  def self.parse_time_from_text(text)
    api_key = ENV['GOOGLE_API_KEY']

    uri = URI.parse("https://language.googleapis.com/v1/documents:analyzeEntities?key=#{api_key}")

    request_body = {
      document: {
        type: "PLAIN_TEXT",
        content: text
      },
      encodingType: "UTF8"
    }.to_json

    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request.body = request_body

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    response_body = JSON.parse(response.body, symbolize_names: true)
    datetime_entity = response_body[:entities].find { |entity| entity[:type] == "DATE" || entity[:type] == "TIME" }
    if datetime_entity
      datetime_entity[:name]
    else
      nil
    end
  end
end
