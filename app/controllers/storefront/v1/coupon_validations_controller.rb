module Storefront::V1
  class CouponValidationsController < ApiController
    
    def create
      #buscando o 'cupom' pelo seu código com o parâmetro 'coupon_code'
      @coupon = Coupon.find_by(code: params[:coupon_code])
      @coupon.validate_use!
      render :show
      #o erro 'NoMethodError' é lançado quando tenta chamar um método que não existe
      #qdo o cupom não existe, levanta a exceção 'NoMethodError'
    rescue Coupon::InvalidUse, NoMethodError
      render_error(message: I18n.t('storefront/v1/coupon_validations.create.failure'))
    end
  
  end
end