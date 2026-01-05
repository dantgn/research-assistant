require 'rails_helper'

RSpec.describe Pubmed::FindArticles do
  subject do
    described_class.new(
      search_query: search_query,
    ).call
  end

  let(:search_query) { 'breast cancer' }
  let(:xml_file_path) { Rails.root.join('spec/support/pubmed_find_articles_response.xml') }

  # Mock the HTTP request to PubMed API
  let(:stub_pubmed_api_request) do
    stub_request(:get, 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi')
      .with(
        query: hash_including(
          db: 'pubmed',
          term: search_query,
          sort: 'relevance',
          retmax: '5',
        ),
      ).to_return(
        status: request_response_status,
        body: request_response_body,
      )
  end

  describe '.call' do
    context 'when search query missing' do
      let(:search_query) { nil }

      it 'should return argument error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when there is an error on PubMed API side' do
      let(:request_response_body) { 'Bad request' }
      let(:request_response_status) { 400 }

      before do
        stub_pubmed_api_request
      end

      it 'should return PubMed Error' do
        expect { subject }.to raise_error(Pubmed::PubmedError, 'PubMed API error (400): Bad request')
      end
    end

    context 'when PubMed API completes successfully' do
      let(:request_response_body) { File.read(xml_file_path) }
      let(:request_response_status) { 200 }

      before do
        stub_pubmed_api_request
      end

      it 'returns a list of article ids' do
        expect(subject).to match(
          %w[32361569 35243878 35115765 34595234 28260181],
        )
      end
    end
  end
end
