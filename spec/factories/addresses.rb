FactoryBot.define do
  factory :address do
    street { Faker::Address.street_name }
    number { Faker::Address.building_number }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    post_code { Faker::Address.postcode }

    #não vai criar a 'Factory' no Banco de Dados
    skip_create
    #para inicializar passando apenas os atributos (padrão do Ruby)
    initialize_with { new(**attributes) }
  end
end