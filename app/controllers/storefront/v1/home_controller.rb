module Storefront::V1
  class HomeController < ApplicationController

    #método que devolve as informações da Home
    def index
      #inicializar o 'service' e chama seu método 'call'
      @loader_service = Storefront::HomeLoaderService.new
      @loader_service.call
    end
  end
end