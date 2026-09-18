# frozen_string_literal: true

module Groq
  class Client
    include HTTParty

    base_uri 'https://api.x.ai/v1'

    def self.chat(model:, input:)
      api_key = ENV.fetch('GROQ_API_KEY', nil)

      response = post(
        '/responses',
        headers: {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{api_key}",
        },
        body: {
          model: model,
          input: input,
        }.to_json,
      )

      raise GroqError, "Groq API error: #{response.body}" unless response.success?

      response.parsed_response
    end
  end
end
