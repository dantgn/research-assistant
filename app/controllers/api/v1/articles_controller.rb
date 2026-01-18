module Api
  module V1
    class ArticlesController < ApplicationController
      def search
        ids = Pubmed::FindArticles.new(search_query: search_params[:query]).call
        articles = Pubmed::FetchArticleDetails.new(ids: ids).call

        articles.each do |article|
          article[:summary] = Groq::SummarizeArticle.new(article: article).call
        end

        render json: { articles: articles }, status: :ok
      rescue Pubmed::PubmedError => e
        render json: { articles: [], error: e.message }, status: 503
      end

      private

      def search_params
        params.permit(:query)
      end
    end
  end
end
