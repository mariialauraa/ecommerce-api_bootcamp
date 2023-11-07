module Storefront::V1
  class CategoriesController < ApplicationController

    def index
      #ordenando por nome
      @categories = Category.order(:name)
    end
  end
end