module Admin
  class AlocateLicensesService

    #recebe o 'LineItem' para o qual queremos alocar as licenças
    def initialize(line_item)
      @line_item = line_item
    end    
    
    def call
      #consulta as licenças disponíveis e pega a mesma qtde de licenças q o campo quantity do 'LineItem'
      licenses = @line_item.product.productable.licenses.where(status: :available).take(@line_item.quantity)
      #chama o método 'update_licenses' e a transaction serve para alocar todas as licenças ou não alocar nenhuma
      License.transaction { update_licenses(licenses) }
      #chama o método 'send_licenses'
      send_licenses
      #após o agendamento dos emails, foi atualizado para ':delivered'
      @line_item.update!(status: :delivered)
    end

    def update_licenses(licenses)
      #percorre cada uma e atualiza os status para 'in_use' e associa com o '@line_item'
      licenses.map { |license| license.attributes = { status: :in_use, line_item: @line_item } }
      licenses.each { |license| license.save! }
    end

    def send_licenses
      #percorre as licenças alocadas para o item de pedido '@line_item'      
      @line_item.licenses.each do |license|
        #e envia um email para cada uma delas utilizando a action 'send_license' do 'LicenseMailer'
        LicenseMailer.with(license: license).send_license.deliver_later
      end
    end

  end
end