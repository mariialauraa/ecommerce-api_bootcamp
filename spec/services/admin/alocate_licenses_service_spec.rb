require "rails_helper"

describe Admin::AlocateLicensesService do
  context "when #call" do
    let!(:order) { create(:order) }
    let!(:line_item) { create(:line_item, order: order) }
    let!(:licenses) { create_list(:license, line_item.quantity, game: line_item.product.productable) }

    #o mesmo número de licenças que a quantidade de item 'LineItem'
    it "allocates same number of licenses as line item quantity" do
      expect do  
        described_class.new(line_item).call
      end.to change(line_item.licenses, :count).by(line_item.quantity)
    end

    #as licenças alocadas recebam o status 'in_use'
    it "licenses receives :in_use status" do
      described_class.new(line_item).call
      licenses_status = line_item.licenses.pluck(:status).uniq
      expect(licenses_status).to eq ['in_use']
    end

    #qdo enviar o email com a licença muda o status para ':delivered status'
    it "line item receives :delivered status" do
      described_class.new(line_item).call
      #recarrega o 'LineItem'
      line_item.reload
      expect(line_item.status).to eq 'delivered'
    end

    #verifica se o email foi enviado
    it "send an email for each allocated license" do
      described_class.new(line_item).call
      line_item.licenses.each do |license|
        #é a responsável por agendar o job de envio de email quando fazemos o envio assíncrono
        #estamos verificando se ela foi agendada para o LicenseMailer
        expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.with(
          'LicenseMailer', 'send_license', 'deliver_now', { params: { license: license }, args: [] }
        )
      end
    end
  end
end