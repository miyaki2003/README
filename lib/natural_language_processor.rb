require 'google/cloud/language'
require 'googleauth'

class NaturalLanguageProcessor
  def self.parse_time_from_text(text)
    credentials = Google::Auth::Credentials.new(JSON.parse(ENV['GOOGLE_CREDENTIALS']))
    language_service = Google::Cloud::Language.language_service(credentials: credentials)

    document = { content: text, type: :PLAIN_TEXT }
    response = language_service.analyze_entities document: document

    datetime_entity = response.entities.find { |entity| entity.type == :DATE_TIME }
    datetime_entity&.metadata['value']
  end
end