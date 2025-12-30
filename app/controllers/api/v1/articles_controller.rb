module Api
  module V1
    class ArticlesController < ApplicationController
      MIN_ARTICLES_LIMIT = 5

      def search
        limit = search_params[:limit] ? [search_params[:limit].to_i, 20].max : MIN_ARTICLES_LIMIT
        ids = Pubmed::FindArticles.new(limit: limit, search_query: search_params[:query]).call
        articles = Pubmed::FetchArticleDetails.new(ids: ids).call

        render json: { articles: articles }, status: 200
      end

      private

      def search_params
        params.permit(:query, :limit)
      end
    end
  end
end
