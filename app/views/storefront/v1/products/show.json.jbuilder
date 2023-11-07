#As parciais são pedaços reutilizáveis de código que podem ser 
#usados para construir partes comuns de suas representações
json.product do
  json.partial! @product
  json.partial! @product.productable
end