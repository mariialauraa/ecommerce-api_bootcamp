module Storefront::V1
  class ProductsController < ApplicationController

    def index
      @service = Storefront::ProductsFilterService.new(search_params)
      @service.call
    end

    def show
      @product = Product.find(params[:id])
    end

    private

    #método para filtrar os parâmetros de busca
    def search_params
      params.permit(:search, :productable, :page, :length, order: {}, category_ids: [], 
                    price: [:min, :max], release_date: [:min, :max]).merge(productable: :game)

    end
  end
end