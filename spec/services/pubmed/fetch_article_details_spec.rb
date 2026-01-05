require 'rails_helper'

RSpec.describe Pubmed::FetchArticleDetails do
  subject do
    described_class.new(
      ids: ids,
    ).call
  end

  let(:ids) do
    %w[32361569 35243878 35115765 34595234 28260181]
  end
  let(:xml_file_path) { Rails.root.join('spec/support/pubmed_fetch_article_details_response.xml') }

  # Mock the HTTP request to PubMed API
  let(:stub_pubmed_api_request) do
    stub_request(:get, 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=32361569&id=35243878&id=35115765&id=34595234&id=28260181&retmode=xml')
      .to_return(
        status: request_response_status,
        body: request_response_body,
      )
  end

  describe '.call' do
    context 'when ids are missing' do
      let(:ids) { [] }

      it 'should return argument error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when ids is nil' do
      let(:ids) { nil }

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

      it 'returns a list of articles with their full details' do
        articles = subject

        expect(articles.count).to eq(5)

        # Check first article parsed data
        first_article = articles.first

        expect(first_article[:title]).to eq('Breast cancer: Biology, biomarkers, and treatments.')
        expect(first_article[:authors].count).to eq(8)
        expect(first_article[:authors].first[:full_name]).to eq('Khadijeh Barzaman')
        expect(first_article[:abstract]).to be_present
        expect(first_article[:pmid]).to eq('32361569')
        expect(first_article[:doi]).to eq('10.1016/j.intimp.2020.106535')
        expect(first_article[:url]).to eq('https://doi.org/10.1016/j.intimp.2020.106535')
      end
    end
  end
end
