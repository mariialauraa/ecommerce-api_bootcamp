module Admin  
    class ModelLoadingService
        attr_reader :records, :pagination

        def initialize(searchable_model, params = {})
            @searchable_model = searchable_model #transforma em uma variável de instancia para ser acessivel no 'call'
            @params = params || {} #se estiver presente vai ser injetado, se não transforma em um hash vazio.
            @records = [] #para armazenar os registros paginados no service
            @pagination = { page: @params[:page].to_i, length: @params[:length].to_i }
        end

        def call
            fix_pagination_values
            filtered = @searchable_model.search_by_name(@params.dig(:search, :name))
            @records = filtered.order(@params[:order].to_h).paginate(@pagination[:page], 
                                                         @pagination[:length])
            total_pages = (filtered.count / @pagination[:length].to_f).ceil #ciel arredonda pro prox. num. maior
            @pagination.merge!(total: filtered.count, total_pages: total_pages)            
        end

        private

        def fix_pagination_values
            @pagination[:page] = @searchable_model.model::DEFAULT_PAGE if @pagination[:page] <= 0
            @pagination[:length] = @searchable_model.model::MAX_PER_PAGE if @pagination[:length] <= 0
        end
    end
end