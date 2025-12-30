# frozen_string_literal: true

module Pubmed
  class FindArticles
    BASE_URL = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi'
    DB_NAME = 'pubmed'
    SORT_TYPE = 'relevance'

    attr_accessor :limit, :search_query

    def initialize(search_query:, limit: 5)
      @search_query = search_query
      @limit = limit
    end

    # Search for Articles in Pubmed database based on a search query
    def call
      response = HTTParty.get(request_uri)
      raise PubmedError, "PubMed API error (#{response.code}): #{response.body}" unless response.success?

      parse_xml(response.body)
    end

    private

    # Build pubmed uri where we will request the article ids
    def request_uri
      uri = URI(BASE_URL)
      uri.query = URI.encode_www_form(
        db: DB_NAME,
        term: search_query,
        sort: SORT_TYPE,
        retmax: limit,
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
