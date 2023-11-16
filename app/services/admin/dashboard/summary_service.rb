module Admin::Dashboard
  class SummaryService
    attr_reader :records

    def initialize(min: nil, max: nil)
      @min_date = min.present? ? min.beginning_of_day : nil
      @max_date = max.present? ? max.end_of_day : nil
      @records = {}
    end

    def call
      #conta quantos usuários existem seguindo o filtro de datas
      @records[:users] = User.where(created_at: @min_date..@max_date).count
      @records[:products] = Product.where(created_at: @min_date..@max_date).count
      calculate_orders
    end

    private

    def calculate_orders
      #o arel ajuda a pegar os elementos de 'Order' e colocar dentro de 'calculate'
      arel = Order.arel_table
      calc = Order.where(status: :finished, created_at: @min_date..@max_date)
                  #pluck retorna os dados num array
                  #flatten deixa apenas um []
                  .pluck(arel[:id].count, arel[:total_amount].sum).flatten 
      @records[:orders] = calc.first #arel[:id].count
      @records[:profit] = calc.second #lucro/faturamento
    end
  end
end