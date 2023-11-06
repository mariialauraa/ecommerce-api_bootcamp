#é o responsável por filtrar os produtos
module Storefront
  class ProductsFilterService
    #atributos 'records' que são os resultados e 'pagination'
    attr_reader :records, :pagination

    #declaramos uma variável para:
    def initialize(params = {})
      @records = Product.all #todos os 'records' que existe no banco na tabela 'Product'
      @params = params || {} #os parâmetros que são enviados
      @pagination = {} #e para a paginação
    end

    def call
      set_pagination_values
      get_available_products
      #caso volte 'Games' repetidos o 'distinct' garante que o q é duplicado, desaparece
      searched = filter_records.select("products.*, games.mode, games.developer, games.release_date").distinct
      #ordena os produtos destes resultados e aplica a paginação
      @records = searched.order(@params[:order].to_h).paginate(@params[:page], @params[:length])
      #chama o método no 'call' passando a quantidade de registros filtrados
      set_pagination_attributes(searched.size)
    end

    private

    #verificamos se os parâmetros foram enviados corretamente e se não, corrigí-mos
    def set_pagination_values
      @params[:page] = @params[:page].to_i
      @params[:length] = @params[:length].to_i
      @params[:page] = Product::DEFAULT_PAGE if @params[:page] <= 0
      @params[:length] = Product::MAX_PER_PAGE if @params[:length] <= 0
    end

    #recebe a quantidade total de registros filtrados,
    #calcula o total de páginas e atribui os valores de paginação em '@pagination'
    def set_pagination_attributes(total_filtered)
      total_pages = (total_filtered / @params[:length].to_f).ceil
      @pagination.merge!(page: @params[:page], length: @records.size, 
                         total: total_filtered, total_pages: total_pages)
    end

    #método para carregar inicialmente apenas os produtos disponíveis
    def get_available_products
      #basicamento colocamos todos os 'Games' associados com as 'categorias'
      @records = @records.joins("JOIN games ON productable_type = 'Game' AND productable_id = games.id")
                         .left_joins(:categories) #injetar os detalhes das categorias
                         .includes(productable: [:game], categories: {})
                         .where(status: :available)
    end

    #método responsável pelos filtros
    def filter_records
      searched = @records.merge filter_by_search
      searched.merge! filter_by_categories
      searched.merge! filter_by_price
      searched.merge! filter_by_release_date
    end

    #método que verifica se a chave search está presente nos parâmetros
    #para filtrar os 'Games' q tenham nome ou descrição ou desenvolvedor igual ao da busca
    def filter_by_search
      return @records.all unless @params.has_key?(:search)
      filtered_records = @records.like(:name, @params[:search]) #se não encontrar
      filtered_records = filtered_records.or(@records.like(:description, @params[:search])) #se não
      filtered_records.or @records.merge(Game.like(:developer, @params[:search]))
    end

    #verifica se existe a chave 'category_ids' e busca os jogos que pertecentam a elas
    def filter_by_categories
      return @records.all unless @params.has_key?(:category_ids)
      @records.where(categories: { id: @params[:category_ids] })
    end

    #filtro por intervalo de preço
    def filter_by_price
      min_price = @params.dig(:price, :min)
      max_price = @params.dig(:price, :max)
      #retorna todos os resultado se os preços estiverem em branco
      return @records.all if min_price.blank? && max_price.blank?
      #se não, faz a busca com o preço 'min' até o preço 'max'
      @records.where(price: min_price..max_price)
    end

    #filtro por intervalo de data
    def filter_by_release_date
      min_date = Time.parse(@params.dig(:release_date, :min)).beginning_of_day rescue nil
      max_date = Time.parse(@params.dig(:release_date, :max)).end_of_day rescue nil
      return @records.all if min_date.blank? && max_date.blank?
      Game.where(release_date: min_date..max_date)
    end
  end
end