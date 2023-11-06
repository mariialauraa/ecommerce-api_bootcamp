json.products do
  json.array! @service.records do |product|
    json.(product, :id, :name, :description)
    json.price product.price.to_f
    json.image_url rails_blob_url(product.image)
    #para obter os nomes das categorias e, em seguida, adicioná-los ao JSON
    json.categories product.categories.pluck(:name)
  end
end

#informações de paginação
json.meta do
  json.partial! 'shared/pagination', pagination: @service.pagination
end