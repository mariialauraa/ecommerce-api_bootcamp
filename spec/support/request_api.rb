module RequestAPI
    def body_json(symbolize_keys: false)
      json = JSON.parse(response.body) #resposta HTTP
      symbolize_keys ? json.deep_symbolize_keys : json
    rescue #trata o erro
      return {} #retorna vazio
    end

    #cabeçalho de autenticação para requisições HTTP 
    def auth_header(user = nil, merge_with: {}) 
        user ||= create(:user)
        auth = user.create_new_auth_token
        header = auth.merge({ 'Content-Type' => 'application/json', 'Accept' => 'application/json' })
        header.merge merge_with #permite adicionar informações extras ao cabeçalho
    end

    #cabeçalho que não precisa de autenticação
    def unauthenticated_header(merge_with: {})
      #indica que é uma requisição do tipo 'json'
      default_header = { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
      default_header.merge merge_with
    end
end

#incluir este módulo dentro do RSpec
RSpec.configure do |config|
    config.include RequestAPI, type: :request
end