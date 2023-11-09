module Storefront
  class CheckoutProcessorService
    class InvalidParamsError < StandardError; end

    #cria uma variável para os 'erros' e outra para o 'pedido'
    attr_reader :errors, :order

    def initialize(params)
      @params = params
      @order = nil
      @errors = {}
    end

    def call      
      check_presence_of_items_param      
      check_emptyness_of_items_param      
      validate_coupon      
      do_checkout
      raise InvalidParamsError if @errors.present?
    end

    private

    #verifica se a chave 'items' existe, se não devolve um erro
    def check_presence_of_items_param
      unless @params.has_key?(:items)
        @errors[:items] = I18n.t('storefront/checkout_processor_service.errors.items.presence')
      end
    end

    #checa se os itens estão preenchidos, se não vieram vazios
    def check_emptyness_of_items_param
      if @params[:items].blank?
        @errors[:items] = I18n.t('storefront/checkout_processor_service.errors.items.empty')
      end
    end

    def validate_coupon
      #retorna apenas se não tiver cupom
      return unless @params.has_key?(:coupon_id)
      #se tiver cupom verifica se ele é váldio
      @coupon = Coupon.find(@params[:coupon_id])
      @coupon.validate_use!
    rescue Coupon::InvalidUse, ActiveRecord::RecordNotFound
      @errors[:coupon] = I18n.t('storefront/checkout_processor_service.errors.coupon.invalid') 
    end
    
    def do_checkout
      #cria o pedido
      create_order
    rescue ActiveRecord::RecordInvalid => e
      @errors.merge! e.record.errors.messages
      @errors.merge!(address: e.record.address.errors.messages) if e.record.errors.has_key?(:address)
    end

    #cria tanto o pedido quanto os seus items
    def create_order
      #se acontecer qualquer erro, ele cancela e volta para o estado anterior 
      Order.transaction do
        #cria a 'order' chamando o método interno 'instantiate_order'
        @order = instantiate_order
        #cria os pedidos 'line_items' e mapeia pois é preciso inicializar cada parâmentro separado
        line_items = @params[:items].map { |line_item_params| instantiate_line_items(line_item_params) }
        #para salvar tanto o pedido quanto os itens
        save!(line_items)
      end
    #se recupera de um possível erro, caso passe valores incorretos
    rescue ArgumentError => e
      @errors[:base] = e.message
    end

    #instancia tanto o pedido 'order' quanto o endereço utilizando 'address'
    def instantiate_order
      #recebe os parâmetros da 'order' q foram passados e pega apenas os necessários 
      order_params = @params.slice(:document, :payment_type, :installments, :card_hash, :coupon_id, :user_id)
      #cria no Banco de Dados a 'order' 
      order = Order.new(order_params)
      #add o campo 'address'
      order.address = Address.new(@params[:address])
      #devolve a 'order'
      order
    end

    #instancia e valida os itens do pedido 
    def instantiate_line_items(line_item_params)
      #cria um novo objeto 'line_item' ao mesmo tempo que add no 'order' 
      line_item = @order.line_items.build(line_item_params)
      #para ter o histórico do preço que foi pago no jogo
      line_item.payed_price = line_item.product.price if line_item.product.present?
      line_item.validate!
      line_item
    end
    
    #salva tanto o pedido quanto os itens 
    def save!(line_items)
      @order.subtotal = line_items.sum(&:total).floor(2)
      @order.total_amount = (@order.subtotal * (1 - @coupon.discount_value / 100)).floor(2) if @coupon.present?
      #pega o montante total (caso tenha cupom) ou o subtotal 
      @order.total_amount ||= @order.subtotal
      @order.save!
      #forma mais enxuta de fazer um 'map' e salva todos eles
      line_items.each(&:save!)
    end

  end
end