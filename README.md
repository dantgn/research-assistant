# README

## Research Assistant

This is an open-source project designed to help the scientific community discover and better understand relevant research articles.

The application integrates with the public NCBI Entrez API to access the PubMed database and retrieve biomedical literature based on user queries.

We use Artificial Intelligence to extract key information from scientific articles and generate concise, structured summaries, helping users quickly grasp the main findings without replacing the original sources.

### Current features:
- Discovering relevant research articles
- Extracting key information from articles

### Start the server

To start the server locally just run `rails server`

### Running Tests

We use RSpec for testing.

In order to test locally just run `rspec`

- If you want to test an specific service run: `rspec spec/services/pubmed/find_articles_spec.rb`
- To test a single spec add the line number at the end: `rspec spec/services/pubmed/find_articles_spec.rb:33`

<br>

###  API Endpoints

#### Search articles - GET /api/v1/search_articles?query=topic&limit=10

Accepts 2 parameters:
- `query`: the topic or field of the articles you want to fetch.
- `limit`: a maximum number of articles that will be returned. 
  - It will return maximum of 5 articles When limit is null.
  - It will return maximum of 10 articles when limit is higher than 10.

This endpoint returns a JSON list of scientific articles with their detailed information, such as title, abstract, authors, url, and a detailed summary of the article.


### How does internally work

#### Groq API key for AI requests 

First, you need to create an account at https://groq.com/ in order to obtain an API token for your requests. There are free plans with limitations.
Once you have the token, to use it locally you need to create an `.env` file and define they key `GROQ_API_KEY=xxxxYYYYYzzzz`.
In production mode you will need to set this key in the enviornment variables as well.


#### Find Articles about a topic, eg: 'Breast cancer'
```
ids = Pubmed::FindArticles.new(limit: 2, search_query: "Breast cancer").call
=> ["32361569", "35243878"]
```


#### Fetch detailed information about the articles found above
```
articles = Pubmed::FetchArticleDetails.new(ids: ids).call
=> 
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
```

#### Summarize Articles
```
first_article = articles.first
summarized_article = Groq::SummarizeArticle.new(article: first_article).call
=>
{
  "objective" => "To present current treatments, novel approaches, and prognostic/predictive biomarkers for breast cancer.",
  "methodology" => "Review of existing treatments, therapies, and biomarkers for breast cancer.",
  "key_results" => "Discussion of antibody-drug conjugation systems, nanoparticles, breast cancer stem cells-based therapies, and prognostic/predictive biomarkers such as Oncotype DX, Mamm αPrint, and uPA/PAI-1.",
  "conclusion" => "Effective treatment of breast cancer is hindered by resistance to therapies, and novel approaches such as ADCs, nanoparticles, and BCSCs-based therapies may offer new avenues for treatment."
}
```

