# frozen_string_literal: true

module Groq
  class SummarizeArticle
    attr_accessor :article

    AI_MODEL = 'grok-4.3'

    def initialize(article:)
      @article = article
    end

    def call
      response = Groq::Client.chat(
        model: AI_MODEL,
        input: [
          { role: 'system', content: 'You are a scientific research assistant.' },
          { role: 'user', content: ai_prompt },
        ],
      )
      summarized_content = response.dig(
        'output', 0,
        'content', 0,
        'text'
      )

      JSON.parse(summarized_content)

    rescue GroqError => e
      {
          objective: "",
          methodology: "",
          key_results: "",
          conclusion: "",
          error: e.message
        }
    end

    private

    def ai_prompt
      <<~TEXT
        Summarize the following scientific abstract.
        Focus on objective, methodology, key results, and conclusion.
        Use concise, factual language.
        Return exclusively a valid JSON
        Do Not include additional text nor markdown.

        Abstract:
        #{article[:abstract]}

        Exact structure:
        {
          objective: "",
          methodology: "",
          key_results: "",
          conclusion: ""
        }
      TEXT
    end
  end
end
