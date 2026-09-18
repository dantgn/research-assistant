# frozen_string_literal: true
module Groq
  class CompareArticles
    AI_MODEL = 'grok-4.3'

    def self.compare(papers)
      summaries = papers.map.with_index do |p, i|
        "Paper #{i + 1}: #{p[:summary]}"
      end.join("\n\n")

      prompt = <<~PROMPT
        Compare the following scientific papers.
        Identify:
        - Common findings
        - Key differences
        - Overall conclusions

        #{summaries}
      PROMPT

      response = GroqClient.chat(
        model: AI_MODEL,
        input: [
          { role: "system", content: "You are a biomedical research analyst." },
          { role: "user", content: prompt }
        ]
      )

      response["choices"][0]["message"]["content"]
    end
  end
end
