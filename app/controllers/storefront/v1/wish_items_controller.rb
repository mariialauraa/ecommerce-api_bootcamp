module Storefront::V1
  class WishItemsController < ApiController #o 'Api' força o usuário a estar logado
    def index
      #está buscando os itens de desejo do usuário e fazendo uma junção com a tabela de produtos
      @wish_items = current_user.wish_items.joins(:product)
                                           .includes(:product) #pré-carregar as informações dos produtos
                                           .order("products.name ASC")                                  
    end

    def create
      #está criando uma nova instância de 'WishItem' associada ao usuário atual
      @wish_item = current_user.wish_items.build(wish_item_params)
      #'!' significa q uma exceção será lançada caso a validação falhe ou ocorra algum erro ao salvar o objeto
      @wish_item.save!
      #mostrará os detalhes do novo 'item de desejo' criado
      render :show 
    #pode ser lançada se a validação do objeto 'WishItem' falhar durante o salvamento
    rescue ActiveRecord::RecordInvalid 
      render_error(fields: @wish_item.errors.messages)
    end

    def destroy
      @wish_item = current_user.wish_items.find(params[:id])
      @wish_item.destroy!
    rescue ActiveRecord::RecordNotFound 
      head :not_found
    end

    private

    #define os parâmetros permitidos que podem ser enviados ao criar ou atualizar um "item de desejo"
    def wish_item_params
      params.require(:wish_item).permit(:product_id)
    end
  end
end