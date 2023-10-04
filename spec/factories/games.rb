FactoryBot.define do
  factory :game do
    mode { %i(pvp pve both).sample } #gerando um array de símbolos
    release_date { '2023-09-27' }
    developer { Faker::Company.name }
    system_requirement #cria automaticamente
  end
end
