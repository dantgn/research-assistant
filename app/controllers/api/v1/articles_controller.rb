module Api
  module V1
    class ArticlesController < ApplicationController
      MIN_ARTICLES_LIMIT = 5
      MAX_ARTICLES_LIMIT = 10

      def search
        limit = search_params[:limit] ? [search_params[:limit].to_i, MAX_ARTICLES_LIMIT].min : MIN_ARTICLES_LIMIT
        ids = Pubmed::FindArticles.new(limit: limit, search_query: search_params[:query]).call
        articles = Pubmed::FetchArticleDetails.new(ids: ids).call

        articles.each do |article|
          article[:summary] = Groq::SummarizeArticle.new(article: article).call
        end

        render json: { articles: articles }, status: :ok
      end

      private

      def search_params
        params.permit(:query, :limit)
      end
    end
  end
end
