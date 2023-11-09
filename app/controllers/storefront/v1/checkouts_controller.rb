module Storefront::V1
  class CheckoutsController < ApiController
    
    def create
      run_service
    rescue Storefront::CheckoutProcessorService::InvalidParamsError
      render_error(fields: @service.errors)
    end

    private

    def run_service
      @service = Storefront::CheckoutProcessorService.new(checkout_params)
      #chama o método onde contém a lógica principal para processar o checkout
      @service.call
      render :show
    end

    #filtra os parâmetros permitidos
    def checkout_params
      params.require(:checkout).permit(:payment_type, :installments, :coupon_id, :card_hash,
                                       :document, items: [:quantity, :product_id],
                                       address: [:street, :number, :city, :state, :post_code])
                               .reverse_merge(user_id: current_user.id, installments: 1)
    end

  end
end