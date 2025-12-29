# frozen_string_literal: true

module Groq
  class SummarizeArticle
    attr_accessor :article

    AI_MODEL = 'llama-3.1-8b-instant'

    def initialize(article:)
      @article = article
    end

    def call
      response = Groq::Client.chat(
        model: AI_MODEL,
        messages: [
          { role: 'system', content: 'You are a scientific research assistant.' },
          { role: 'user', content: ai_message },
        ],
      )

      response['choices'][0]['message']['content']
    end

    private

    def ai_message
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
