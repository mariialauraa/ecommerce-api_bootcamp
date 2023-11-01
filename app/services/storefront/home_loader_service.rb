module Storefront
  # carrega os dados da Home
  class HomeLoaderService
    QUANTITY_OF_RECORDS_PER_GROUP = 4 #constante de qtos elementos é pra retornar
    MIN_RELEASE_DAYS = 7 #constante de qtos dias o jogo é considerado lançamento ou não

    # atributos que vão ser lidos de fora do service
    attr_reader :featured, :last_releases, :cheapest

    # método que inicializa as variáveis como vazias
    def initialize
      @featured = []
      @recently_releases = []
      @cheapest = []
    end

    # método q faz um JOIN(juntar) de Product com Game e filtrar somente os produtos disponíveis
    def call
      games = Product.joins("JOIN games ON productable_type = 'Game' AND productable_id = games.id")
                     .includes(productable: [:game]).where(status: :available)

      # chama os método no call atribuindo às variáveis de inicialização
      @featured = load_featured_games(games)
      @last_releases = load_last_released_games(games)
      @cheapest = load_cheapest_games(games)
    end

    private

    # método para pegar jogos em destaque e filtrar a qtde que vai ser devolvida
    def load_featured_games(games)
      games.where(featured: true).sample(QUANTITY_OF_RECORDS_PER_GROUP)
    end

    # método que filtra o lançamento entre 7 dias atrás e hoje
    # e também pegue 4 registros aleatórios
    def load_last_released_games(games)
      games.where(games: { release_date: MIN_RELEASE_DAYS.days.ago.beginning_of_day..Time.now.end_of_day })
           .sample(QUANTITY_OF_RECORDS_PER_GROUP)
    end

    # método que filtra os mais baratos e orderna crescentemente por preço
    # e também pega os 4 primeiros registros
    def load_cheapest_games(games)
      games.order(price: :asc).take(QUANTITY_OF_RECORDS_PER_GROUP)
    end

  end
end