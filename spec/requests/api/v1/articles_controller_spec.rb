require 'swagger_helper'

RSpec.describe Api::V1::ArticlesController, type: :request do
  include AutoSchemaGenerator

  path '/api/v1/search_articles' do
    get 'Fetch scientific articles with AI summary' do
      tags 'Articles'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :query, in: :query, type: :string, required: true, description: 'the topic or research area of the articles you want to retrieve'

      let(:query) { 'breast cancer' }
      let(:find_articles_service) { instance_double(Pubmed::FindArticles) }
      let(:fetch_article_details_service) { instance_double(Pubmed::FetchArticleDetails) }
      let(:groq_sumarize_service) { instance_double(Groq::SummarizeArticle) }

      let(:ids) { %w[32361569 35243878 35115765 34595234 28260181] }
      let(:articles) { article_examples }

      let(:article_summary) do
        {
          'objective' => '',
          'methodology' => '',
          'key_results' => '',
          'conclusion' => '',
        }
      end

      before do
        # We Mock the services as they are tested in separate specs
        allow(Pubmed::FindArticles)
          .to receive(:new)
          .with(any_args)
          .and_return(find_articles_service)

        allow(find_articles_service).to receive(:call).and_return(ids)

        allow(Pubmed::FetchArticleDetails)
          .to receive(:new)
          .with(any_args)
          .and_return(fetch_article_details_service)

        allow(fetch_article_details_service).to receive(:call).and_return(articles)

        allow(Groq::SummarizeArticle)
          .to receive(:new)
          .with(any_args)
          .and_return(groq_sumarize_service)

        allow(groq_sumarize_service).to receive(:call).and_return(article_summary)
      end

      response '200', 'success response' do
        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body['articles'].count).to eq(2)
        end
      end
    end
  end

  private 

  def article_examples
    [
      {
        :title=>"Breast cancer: Biology, biomarkers, and treatments.",
        :abstract=>
          "During the past recent years, various therapies emerged in the era of breast cancer. Breast cancer is a heterogeneous disease in which genetic and environmental factors are involved. Breast cancer stem cells (BCSCs) are the main player in the aggressiveness of different tumors and also, these cells are the main challenge in cancer treatment. Moreover, the major obstacle to achieve an effective treatment is resistance to therapies. There are various types of treatment for breast cancer (BC) patients. Therefore, in this review, we present the current treatments, novel approaches such as antibody-drug conjugation systems (ADCs), nanoparticles (albumin-, metal-, lipid-, polymer-, micelle-based nanoparticles), and BCSCs-based therapies. Furthermore, prognostic and predictive biomarkers will be discussed also biomarkers that have been applied by some tests such as Oncotype DX, Mamm αPrint, and uPA/PAI-1 are regarded as suitable prognostic and predictive factors in breast cancer.",
      :authors=>
       [
        {
          :full_name=>"Khadijeh Barzaman",
          :last_name=>"Barzaman",
          :fore_name=>"Khadijeh",
          :initials=>"K",
          :affiliations=>
            ["Department of Immunology, School of Medicine, Iran University of Medical Sciences, Tehran, Iran; Recombinant Proteins Department, Breast Cancer Research Center, Motamed Cancer Institute, ACECR, Tehran, Iran."]
        },
        {
          :full_name=>"Jafar Karami",
          :last_name=>"Karami",
          :fore_name=>"Jafar",
          :initials=>"J",
          :affiliations=>
            ["Department of Immunology, School of Medicine, Iran University of Medical Sciences, Tehran, Iran; Rheumatology Research Center, Tehran University of Medical Sciences, Tehran, Iran."]
          },
        {
          :full_name=>"Zeinab Zarei",
          :last_name=>"Zarei",
          :fore_name=>"Zeinab",
          :initials=>"Z",
          :affiliations=>["Department of Biomaterials and Tissue Engineering, Breast Cancer Research Center, Motamed Cancer Institute, ACECR, Tehran, Iran."]
        },
        {
          :full_name=>"Aysooda Hosseinzadeh",
          :last_name=>"Hosseinzadeh",
          :fore_name=>"Aysooda",
          :initials=>"A",
          :affiliations=>["Recombinant Proteins Department, Breast Cancer Research Center, Motamed Cancer Institute, ACECR, Tehran, Iran."]
        },
        {
          :full_name=>"Mohammad Hossein Kazemi",
          :last_name=>"Kazemi",
          :fore_name=>"Mohammad Hossein",
          :initials=>"MH",
          :affiliations=>
            ["Student Research Committee, Department of Immunology, School of Medicine, Iran University of Medical Science, Tehran, Iran; ATMP Department, Breast Cancer Research Center, Motamed Cancer Institute, ACECR, Tehran, Iran."]
        },
        {
          :full_name=>"Shima Moradi-Kalbolandi",
          :last_name=>"Moradi-Kalbolandi",
          :fore_name=>"Shima",
          :initials=>"S",
          :affiliations=>["Recombinant Proteins Department, Breast Cancer Research Center, Motamed Cancer Institute, ACECR, Tehran, Iran."]
        },
        {
          :full_name=>"Elahe Safari",
          :last_name=>"Safari",
          :fore_name=>"Elahe",
          :initials=>"E",
          :affiliations=>
            ["Department of Immunology, School of Medicine, Iran University of Medical Sciences, Tehran, Iran; Immunology Research Center, Iran University of Medical Sciences, Tehran, Iran. Electronic address: el.safari@yahoo.com."]
        },
        {
          :full_name=>"Leila Farahmand",
          :last_name=>"Farahmand",
          :fore_name=>"Leila",
          :initials=>"L",
          :affiliations=>
            ["Recombinant Proteins Department, Breast Cancer Research Center, Motamed Cancer Institute, ACECR, Tehran, Iran. Electronic address: laylafarahmand@gmail.com."]
          }
        ],
        :pmid=>"32361569",
        :doi=>"10.1016/j.intimp.2020.106535",
        :url=>"https://doi.org/10.1016/j.intimp.2020.106535"
      },
      {
        :title=>"Breast cancer: presentation, investigation and management.",
        :abstract=>
          "Breast cancer is the most common global malignancy and the leading cause of cancer deaths. Despite this, undergraduate and postgraduate exposure to breast cancer is limited, impacting on the ability of clinicians to accurately recognise, assess and refer appropriate patients. This article provides a comprehensive review of the pathology, epidemiology, clinical presentation, referral pathways and management of breast cancer in the UK. It also describes how to conduct a thorough clinical breast examination.",
        :authors=>
          [
            {
              :full_name=>"Chie Katsura",
              :last_name=>"Katsura",
              :fore_name=>"Chie",
              :initials=>"C",
              :affiliations=>["Department of Breast Surgery, Colchester Hospital, East Suffolk and North Essex NHS Foundation Trust, Essex, UK."]
            },
            {
              :full_name=>"Innocent Ogunmwonyi",
              :last_name=>"Ogunmwonyi",
              :fore_name=>"Innocent",
              :initials=>"I",
              :affiliations=>["Department of Surgery, University Hospital Lewisham, Lewisham and Greenwich NHS Foundation Trust, London, UK."]
            },
            {:full_name=>"Hadyn Kn Kankam",
              :last_name=>"Kankam",
              :fore_name=>"Hadyn Kn",
              :initials=>"HK",
              :affiliations=>["Department of Breast Surgery, Colchester Hospital, East Suffolk and North Essex NHS Foundation Trust, Essex, UK."]
            },
            {
              :full_name=>"Sunita Saha",
              :last_name=>"Saha",
              :fore_name=>"Sunita",
              :initials=>"S",
              :affiliations=>["Department of Breast Surgery, Colchester Hospital, East Suffolk and North Essex NHS Foundation Trust, Essex, UK."]
            }
          ],
        :pmid=>"35243878",
        :doi=>"10.12968/hmed.2021.0459",
        :url=>"https://doi.org/10.12968/hmed.2021.0459"
      }
    ]
  end
end
