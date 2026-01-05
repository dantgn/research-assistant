# frozen_string_literal: true

module Pubmed
  class FindArticles
    BASE_URL = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi'
    DB_NAME = 'pubmed'
    SORT_TYPE = 'relevance'
    LIMIT_ARTICLES = 5

    attr_accessor :search_query

    def initialize(search_query:)
      @search_query = search_query
    end

    # Search for Articles in Pubmed database based on a search query
    def call
      validate_params

      response = HTTParty.get(request_uri)
      raise PubmedError, "PubMed API error (#{response.code}): #{response.body}" unless response.success?

      parse_xml(response.body)
    end

    private

    def validate_params
      return if search_query.present?

      raise ArgumentError, 'Search query is missing, please tell us what to look for.'
    end

    # Build pubmed uri where we will request the article ids
    def request_uri
      uri = URI(BASE_URL)
      uri.query = URI.encode_www_form(
        db: DB_NAME,
        term: search_query,
        sort: SORT_TYPE,
        retmax: LIMIT_ARTICLES,
      )
      uri
    end

    # Find article pmids within xml response
    def parse_xml(body)
      doc = Nokogiri::XML(body)
      doc.xpath('//IdList/Id').map(&:text)
    end
  end
end
