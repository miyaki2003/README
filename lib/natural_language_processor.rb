require "google/cloud/language"

class NaturalLanguageProcessor
  def self.parse_time_from_text(text)
    project_id = "instant-subset-417305"
    language = Google::Cloud::Language.language_service
    document = { content: text, type: :PLAIN_TEXT }
    response = language.analyze_entities document: document
    datetime_entities = response.entities.select { |entity| entity.type == "DATE" || entity.type == "NUMBER" }
    datetime_entities.map { |entity| entity.metadata['value'] }.compact
  end
end