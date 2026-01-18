# frozen_string_literal: true

module Groq
  class Client
    include HTTParty

    base_uri 'https://api.groq.com/openai/v1'

    def self.chat(model:, messages:, temperature: 0.2)
      api_key = ENV.fetch('GROQ_API_KEY', nil)

      response = post(
        '/chat/completions',
        headers: {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{api_key}",
        },
        body: {
          model: model,
          messages: messages,
          temperature: temperature,
        }.to_json,
      )

      raise GroqError, "Groq API error: #{response.body}" unless response.success?

      response.parsed_response
    end
  end
end
