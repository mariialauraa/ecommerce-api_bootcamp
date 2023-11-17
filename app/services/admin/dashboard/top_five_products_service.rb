module Admin::Dashboard
  class TopFiveProductsService
    NUMBER_OF_RECORDS = 5 #top5

    attr_reader :records

    def initialize(min: nil, max: nil)
      @min_date = min.present? ? min.beginning_of_day : nil
      @max_date = max.present? ? max.end_of_day : nil
      @records = []
    end

    def call
      #percorre o q é retornado pelo 'search_top_five' 
      @records = search_top_five.map do |product|
        #responsável por criar um 'hash' com os dados de cada produto
        build_product_hash(product)
      end
      @records
    end

    private

    def search_top_five
      #filtra os pedidos a partir desse 'range'
      range_date_orders = Order.where(status: :finished, created_at: @min_date..@max_date)
      #pega os produtos que estejam nestes pedidos e agrupa pelo id do produto
      Product.joins(line_items: :order).merge(range_date_orders).group(:id)
              #ordenar de forma descendente os produtos pelo total vendido e pela qtde vendida
             .order('total_sold DESC, total_qty DESC')
             .limit(NUMBER_OF_RECORDS) #top5
             #seleciona o que será devolvido para o usuário e renomeia utilizando 'as'
             .select(:id, :name, line_item_arel[:sold].as('total_sold'), line_item_arel[:quantity].as('total_qty'))
    end

    def build_product_hash(product)
      #devolve um 'hash' {}
      { 
        product: product.name, 
        image: Rails.application.routes.url_helpers.rails_blob_path(product.image, only_path: false), 
        total_sold: product.total_sold, 
        quantity: product.total_qty 
     }
    end

    def line_item_arel
      #retona a '@line_item_arel' caso ela já esteja preenchida
      return @line_item_arel if @line_item_arel
      #armazena o objeto 'arel_table' de 'LineItem' numa variável 'arel'
      arel = LineItem.arel_table
      #multiplica o preço pago por um produto pela sua qtde e soma esses valores
      total_sold = (arel[:payed_price] * arel[:quantity]).sum
      #soma as quantidades, para saber quantos foram vendidos
      quantity_sum = arel[:quantity].sum
      #armazena as duas operações em uma variável de instância
      @line_item_arel = { sold: total_sold, quantity: quantity_sum }
    end
  end
end