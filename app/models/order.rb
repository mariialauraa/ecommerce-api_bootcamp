class Order < ApplicationRecord
  include Paginatable

  DAYS_TO_DUE = 7 #constante

  #atributos virtuais, não são salvos no Banco de Dados
  attribute :address
  attribute :card_hash
  attribute :document

  belongs_to :user
  belongs_to :coupon, optional: true
  has_many :line_items
  has_many :juno_charges, class_name: 'Juno::Charge'

  validates :status, presence: true, on: :update
  validates :subtotal, presence: true, numericality: { greater_than: 0 }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_type, presence: true
  #números de vezes da parcela
  validates :installments, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :document, presence: true, cpf_cnpj: true, on: :create  

  #validar a presença somente se o pagamento for com cartão de crédito
  with_options if: ->{ credit_card? }, on: :create do
    validates :card_hash, presence: true
    validates :address, presence: true
    #para evitar que um endereço incompleto seja passado no momento da geração de um pedido
    validates_associated :address
  end

  enum status: { processing_order: 1, processing_error: 2, waiting_payment: 3,
                 payment_accepted: 4, payment_denied: 5, finished: 6 }

  enum payment_type: { credit_card: 1, billet: 2 }

  #chama o método antes da validação apenas durante a criação
  before_validation :set_default_status, on: :create

  #chama o 'ship_order' no momento correto, durante a atualização
  around_update :ship_order, if: -> { self.status_changed?(to: 'payment_accepted') }

  #método da data de vencimento
  def due_date
    self.created_at + DAYS_TO_DUE.days
  end

  private

  def set_default_status
    self.status = :processing_order
  end

  #chama esse método qdo a 'order' mudar de status
  def ship_order
    #serve para sinalizar em que momento do 'around_update' queremos processar a atualização
    yield
    #dispara o método 'ship!' em cada 'line_item' no pedido
    self.line_items.each { |line_item| line_item.ship! }
  end
end
