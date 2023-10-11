module Admin  
  class ProductSavingService
    class NotSavedProductError < StandardError; end

    attr_reader :product, :errors

    def initialize(params, product = nil)
      params = params.deep_symbolize_keys #transforma em símbolo o q recebemos como parametro
      @product_params = params.reject { |key| key == :productable_attributes } #retira/rejeita os parâmetros do productable (Game)
      @productable_params = params[:productable_attributes] || {}
      @errors = {}
      @product = product || Product.new #usa o que foi passado ou cria um novo
    end

    def call
      Product.transaction do #caso algum erro ocorra durante o processo, nada será salvo no banco
        @product.attributes = @product_params.reject { |key| key == :productable }
        build_productable #serve para criar o productable
      ensure #vai garantir que o proximo metodo seja rodado (save!)
        save!
      end    
    end

    def build_productable
      @product.productable ||= @product_params[:productable].camelcase.safe_constantize.new #ou o productable já existe ou cria um novo
      @product.productable.attributes = @productable_params
    end

    def save!
      save_record!(@product.productable) if @product.productable.present?
      save_record!(@product)
      raise NotSavedProductError if @errors.present? #levantar o erro se estiver presente
    rescue => e #se recuperar do erro
      raise NotSavedProductError
    end

    def save_record!(record)
      record.save!
    rescue ActiveRecord::RecordInvalid #vai se recuperar desse erro
      @errors.merge!(record.errors.messages)
    end
  end
end