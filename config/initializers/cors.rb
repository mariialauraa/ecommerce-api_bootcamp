Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*' #quais os domínios vamos aceitar.

    resource '*', #'*' - todos.
    headers: :any, 
    methods: [:get, :post, :put, :patch, :delete]
  end
end