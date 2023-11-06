require "rails_helper"

#serve para testar as possibilidades das buscas
describe Storefront::ProductsFilterService do
  context "when #call" do
    let!(:general_products) { create_list(:product, 15) }

    #busca sem nenhum filtro
    context "without any filter" do
      it "returns 10 records" do
        service = described_class.new
        service.call
        expect(service.records.size).to eq 10
      end
      
      it "returns right products" do
        #Cria uma instância de 'service', onde 'described_class' é à classe que está sendo testada
        service = described_class.new
        service.call
        #A expectativa será satisfeita se a expressão no bloco retornar verdadeiro
        expect(service.records.to_a).to satisfy do |records|
          #está verificando se a interseção é igual a todos os registros,
          #os registros retornados pelo 'service' são um subconjunto de 'general_products'
          records & general_products == records
        end
      end

      it "sets right :page" do
        service = described_class.new
        service.call
        expect(service.pagination[:page]).to eq 1
      end

      it "sets right :length" do
        service = described_class.new
        service.call
        expect(service.pagination[:length]).to eq 10
      end

      it "sets right :total" do
        service = described_class.new
        service.call
        expect(service.pagination[:total]).to eq 15
      end

      it "sets right :total_pages" do
        service = described_class.new
        service.call
        expect(service.pagination[:total_pages]).to eq 2
      end
    end

    #busca com filtro
    context "with search filter" do
      #cria variáveis locais que são avaliadas imediatamente quando o contexto é executado
      let!(:search_products) do
        products = [] 
        5.times { |n| products << create(:product, name: "Search #{n + 1}") }
        5.times { |n| products << create(:product, description: "Some kind of search #{n + 1}") }
        5.times do |n|
          game = create(:game, developer: "Search #{n + 1}")
          products << create(:product, productable: game)
        end
        products 
      end

      #variável local 'params'
      #e um hash (conjunto de pares chave-valor) que contém duas chaves: 'search' e 'productable'
      let(:params) { { search: "Search", productable: 'game' } }

      it "returns 10 records" do
        service = described_class.new(params)
        service.call
        expect(service.records.size).to eq 10
      end
      
      it "returns right products" do
        service = described_class.new(params)
        service.call
        expect(service.records).to satisfy do |records|
          records & search_products == records
        end
      end

      it "does not return unenexpected records" do
        params.merge!(page: 1, length: 50)
        service = described_class.new(params)
        service.call
        expect(service.records).to_not include *general_products
      end

      it "sets right :page" do
        service = described_class.new(params)
        service.call
        expect(service.pagination[:page]).to eq 1
      end

      it "sets right :length" do
        service = described_class.new(params)
        service.call
        expect(service.pagination[:length]).to eq 10
      end

      it "sets right :total" do
        service = described_class.new(params)
        service.call
        expect(service.pagination[:total]).to eq 15
      end

      it "sets right :total_pages" do
        service = described_class.new(params)
        service.call
        expect(service.pagination[:total_pages]).to eq 2
      end
    end

    #busca com filtro na categoria
    context "with category filter" do
      let!(:categories) { create_list(:category, 3) }
      #é usada para criar uma lista de 15 produtos, onde cada produto é associado a duas categorias
      #selecionadas aleatoriamente a partir das categorias criadas anteriormente em 'categories'
      let!(:categories_products) { create_list(:product, 15, category_ids: categories.map(&:id).sample(2)) }

      let(:params) { { category_ids: categories.map(&:id) } }

      it "returns 10 records" do
        service = described_class.new(params)
        service.call
        expect(service.records.size).to eq 10
      end
      
      it "returns right products" do
        service = described_class.new(params)
        service.call
        expect(service.records.to_a).to satisfy do |records|
          records & categories_products == records
        end
      end

      it "does not return unenexpected records" do
        params.merge!(page: 1, length: 50)
        service = described_class.new(params)
        service.call
        expect(service.records).to_not include *general_products
      end

      it "sets right :page" do
        service = described_class.new(params)
        service.call
        expect(service.pagination[:page]).to eq 1
      end

      it "sets right :length" do
        service = described_class.new(params)
        service.call
        expect(service.pagination[:length]).to eq 10
      end

      it "sets right :total" do
        service = described_class.new(params)
        service.call
        expect(service.pagination[:total]).to eq 15
      end

      it "sets right :total_pages" do
        service = described_class.new(params)
        service.call
        expect(service.pagination[:total_pages]).to eq 2
      end
    end

    #busca com filtro no preço
    context "with price filter" do
      let!(:lower_prices_products) do 
        products = []
        #é criado com um preço gerado aleatoriamente dentro da faixa
        #de 10.0 (inclusivo) a 30.0 (exclusivo)
        5.times { |n| products << create(:product, price: Faker::Commerce.price(range: 10.0...30.0)) }
        products
      end

      let!(:higher_price_products) do 
        products = []
        #é criado com um preço gerado aleatoriamente dentro da faixa
        #de 30.0 (inclusivo) a 50.0 (inclusivo) 
        5.times { |n| products << create(:product, price: Faker::Commerce.price(range: 30.0..50.0)) }
        products
      end

      #apenas o valor mínimo de preço deve ser cumprido
      context "only :min fulfilled" do
        #o teste deve verificar se o sistema é capaz de retornar produtos
        #cujo preço seja igual ou maior que 30.0
        let(:params) { { price: { min: 30.0 } } }

        it "returns 10 records" do
          service = described_class.new(params)
          service.call
          expect(service.records.size).to eq 10
        end
        
        it "returns right products" do
          service = described_class.new(params)
          service.call
          expect(service.records).to satisfy do |records|
            records & (higher_price_products + general_products) == records
          end
        end

        it "does not return unenexpected records" do
          params.merge!(page: 1, length: 50)
          service = described_class.new(params)
          service.call
          expect(service.records).to_not include *lower_prices_products
        end
  
        it "sets right :page" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:page]).to eq 1
        end
  
        it "sets right :length" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:length]).to eq 10
        end
  
        it "sets right :total" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:total]).to eq 20
        end
  
        it "sets right :total_pages" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:total_pages]).to eq 2
        end
      end

      #apenas o valor máximo de preço deve ser cumprido
      context "only :max fulfilled" do
        #o teste deve verificar se o sistema é capaz de retornar produtos
        #cujo preço seja igual ou inferior a 30.0
        let(:params) { { price: { max: 30.0 } } }

        it "returns 10 records" do
          service = described_class.new(params)
          service.call
          expect(service.records.size).to eq 5
        end
        
        it "returns right products" do
          service = described_class.new(params)
          service.call
          expect(service.records).to satisfy do |records|
            records & lower_prices_products == records
          end
        end

        it "does not return unenexpected records" do
          params.merge!(page: 1, length: 50)
          service = described_class.new(params)
          service.call
          expect(service.records).to_not include *(higher_price_products + general_products)
        end
  
        it "sets right :page" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:page]).to eq 1
        end
  
        it "sets right :length" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:length]).to eq 5
        end
  
        it "sets right :total" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:total]).to eq 5
        end
  
        it "sets right :total_pages" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:total_pages]).to eq 1
        end
      end

      context "both :min and :max fulfilled" do
        #o teste deve verificar se o sistema é capaz de retornar produtos 
        #cujo preço esteja dentro dessa faixa de 10.0 a 50.0
        let(:params) { { price: { min: 10.0, max: 50.0 } } }

        it "returns 10 records" do
          service = described_class.new(params)
          service.call
          expect(service.records.size).to eq 10
        end
        
        it "returns right products" do
          service = described_class.new(params)
          service.call
          expect(service.records).to satisfy do |records|
            records & (lower_prices_products + higher_price_products) == records
          end
        end

        it "does not return unenexpected records" do
          params.merge!(page: 1, length: 50)
          service = described_class.new(params)
          service.call
          expect(service.records).to_not include *general_products
        end
  
        it "sets right :page" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:page]).to eq 1
        end
  
        it "sets right :length" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:length]).to eq 10
        end
  
        it "sets right :total" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:total]).to eq 10
        end
  
        it "sets right :total_pages" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:total_pages]).to eq 1
        end
      end
    end

    #busca com filtro na data de lançamento
    context "with release date filter" do
      let!(:recently_released_products) do 
        products = []
        5.times do |n| 
          game = create(:game, release_date: (0..7).to_a.sample.days.ago)
          products << create(:product, productable: game)
        end
        products
      end

      let!(:older_products) do 
        products = []
        5.times do |n| 
          game = create(:game, release_date: (8..14).to_a.sample.days.ago)
          products << create(:product, productable: game)
        end
        products
      end

      context "only :min fulfilled" do
        let(:params) { { release_date: { min: 7.days.ago.to_s } } }

        it "returns 5 records" do
          service = described_class.new(params)
          service.call
          expect(service.records.size).to eq 5
        end
        
        it "returns right products" do
          service = described_class.new(params)
          service.call
          expect(service.records).to satisfy do |records|
            records & recently_released_products == records
          end
        end

        it "does not return unenexpected records" do
          params.merge!(page: 1, length: 50)
          service = described_class.new(params)
          service.call
          expect(service.records).to_not include *(older_products + general_products)
        end
  
        it "sets right :page" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:page]).to eq 1
        end
  
        it "sets right :length" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:length]).to eq 5
        end
  
        it "sets right :total" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:total]).to eq 5
        end
  
        it "sets right :total_pages" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:total_pages]).to eq 1
        end
      end

      context "only :max fulfilled" do
        let(:params) { { release_date: { max: 8.days.ago.to_s } } }

        it "returns 10 records" do
          service = described_class.new(params)
          service.call
          expect(service.records.size).to eq 10
        end
        
        it "returns right products" do
          service = described_class.new(params)
          service.call
          expect(service.records).to satisfy do |records|
            records & (older_products + general_products) == records
          end
        end

        it "does not return unenexpected records" do
          params.merge!(page: 1, length: 50)
          service = described_class.new(params)
          service.call
          expect(service.records).to_not include *recently_released_products
        end
  
        it "sets right :page" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:page]).to eq 1
        end
  
        it "sets right :length" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:length]).to eq 10
        end
  
        it "sets right :total" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:total]).to eq 20
        end
  
        it "sets right :total_pages" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:total_pages]).to eq 2
        end
      end

      context "both :min and :max fulfilled" do
        let(:params) do 
          { release_date: { min: 14.days.ago.to_s, max: Time.zone.now.to_s } }
        end

        it "returns 10 records" do
          service = described_class.new(params)
          service.call
          expect(service.records.size).to eq 10
        end
        
        it "returns right products" do
          service = described_class.new(params)
          service.call
          expect(service.records).to satisfy do |records|
            records & (recently_released_products + older_products) == records
          end
        end

        it "does not return unenexpected records" do
          params.merge!(page: 1, length: 50)
          service = described_class.new(params)
          service.call
          expect(service.records).to_not include *general_products
        end
  
        it "sets right :page" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:page]).to eq 1
        end
  
        it "sets right :length" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:length]).to eq 10
        end
  
        it "sets right :total" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:total]).to eq 10
        end
  
        it "sets right :total_pages" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:total_pages]).to eq 1
        end
      end
    end

    #busca com a paginação dos parâmetros
    context "with pagination params" do
      let(:page) { 2 }
      let(:length) { 5 }

      let(:params) { { page: page, length: length } }

      it "returns records sized by :length" do
        service = described_class.new(params)
        service.call
        expect(service.records.size).to eq length
      end
      
      it "returns products limited by pagination" do
        service = described_class.new(params)
        service.call
        expect(service.records).to satisfy do |records|
          records & general_products == records
        end
      end

      it "sets right :page" do
        service = described_class.new(params)
        service.call
        expect(service.pagination[:page]).to eq 2
      end

      it "sets right :length" do
        service = described_class.new(params)
        service.call
        expect(service.pagination[:length]).to eq 5
      end

      it "sets right :total" do
        service = described_class.new(params)
        service.call
        expect(service.pagination[:total]).to eq 15
      end

      it "sets right :total_pages" do
        service = described_class.new(params)
        service.call
        expect(service.pagination[:total_pages]).to eq 3
      end
    end

    #busca com a ordem dos parâmetros
    context "with order params" do
      context "by price" do
        let(:params) { { order: { price: 'desc' } } }

        it "returns 10 records" do
          service = described_class.new(params)
          service.call
          expect(service.records.size).to eq 10
        end

        it "returns ordered products limited by default pagination" do
          service = described_class.new(params)
          service.call
          general_products.sort! { |a, b| b[:price] <=> a[:price] }
          expect(service.records.to_a).to satisfy do |records|
            records & general_products == records
          end
        end
  
        it "sets right :page" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:page]).to eq 1
        end

        it "sets right :length" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:length]).to eq 10
        end

        it "sets right :total" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:total]).to eq 15
        end

        it "sets right :total_pages" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:total_pages]).to eq 2
        end
      end

      context "by release date" do
        let(:params) { { order: { release_date: 'desc' } } }

        it "returns 10 records" do
          service = described_class.new(params)
          service.call
          expect(service.records.size).to eq 10
        end

        it "returns ordered products limited by default pagination" do
          service = described_class.new(params)
          service.call
          general_products.sort! { |a, b| b[:release_date] <=> a[:release_date] }
          expect(service.records.to_a).to satisfy do |records|
            records & general_products == records
          end
        end
  
        it "sets right :page" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:page]).to eq 1
        end

        it "sets right :length" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:length]).to eq 10
        end

        it "sets right :total" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:total]).to eq 15
        end

        it "sets right :total_pages" do
          service = described_class.new(params)
          service.call
          expect(service.pagination[:total_pages]).to eq 2
        end
      end
    end
  end
end