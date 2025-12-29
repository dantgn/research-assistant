# frozen_string_literal: true

module Pubmed
  class FetchArticleDetails
    BASE_URL = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi'
    DB_NAME = 'pubmed'
    RESPONSE_TYPE = 'xml' # json is not working well

    attr_accessor :ids

    def initialize(ids:)
      @ids = ids
    end

    # Search for Articles information from Pubmed database based on their pmids
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
        id: ids,
        retmode: RESPONSE_TYPE,
      )
      uri
    end

    # Find articles information within xml response
    def parse_xml(body)
      doc = Nokogiri::XML(body)
      articles = []
      doc.xpath('//PubmedArticle').each do |article|
        articles << build_article(article)
      end
      articles
    end

    # Build Article based pm xml reqponse data
    def build_article(article)
      title = article.at_xpath('.//ArticleTitle')&.text
      abstract_nodes = article.xpath('.//AbstractText')
      abstract = abstract_nodes.map do |node|
        label = node['Label']
        text = node.text
        label ? "#{label}: #{text}" : text
      end.join(' ')
      article_ids = article.xpath('.//ArticleId').each_with_object({}) do |id, hash|
        hash[id['IdType']] = id.text
      end

      info = {
        title: title,
        abstract: abstract.presence || 'Abstract information not available',
        authors: build_authors(article),
      }
      info.merge!(pmid: article_ids['pubmed']) if article_ids['pubmed']
      info.merge!(doi: article_ids['doi']) if article_ids['doi']
      info.merge!(pmc: article_ids['pmc']) if article_ids['pmc']
      info[:url] = build_article_url(
        pmid: article_ids['pubmed'],
        doi: article_ids['doi'],
        pmcid: article_ids['pmc'],
      )
      info
    end

    def build_article_url(pmid:, doi:, pmcid:)
      # try first with pmcid as doi might need payment access
      return "https://www.ncbi.nlm.nih.gov/pmc/articles/#{pmcid}/" if pmcid.present?
      return "https://doi.org/#{doi}" if doi.present?

      "https://pubmed.ncbi.nlm.nih.gov/#{pmid}/"
    end

    def build_authors(article)
      authors = []
      article.xpath('.//AuthorList/Author').each do |author|
        # Case 1: collective author
        collective = author.at_xpath('./CollectiveName')&.text
        if collective.present?
          authors << { collective_name: collective }
          next
        end
        # Case 2: individual author
        last_name  = author.at_xpath('./LastName')&.text
        fore_name  = author.at_xpath('./ForeName')&.text
        initials   = author.at_xpath('./Initials')&.text
        affiliations = author.xpath('.//Affiliation').map(&:text)
        full_name = [fore_name, last_name].compact.join(' ')

        authors << {
          full_name: full_name,
          last_name: last_name,
          fore_name: fore_name,
          initials: initials,
          affiliations: affiliations,
        }
      end
      authors
    end
  end
end
