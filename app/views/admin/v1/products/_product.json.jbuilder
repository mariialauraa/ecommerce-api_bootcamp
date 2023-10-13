#partial responsável por devolver informações de um produto:
json.(product, :id, :name, :description, :price, :status)
json.image_url rails_blob_url(product.image)
json.productable product.productable_type.underscore #passa para o usuário o tipo de productable q ta associado 
json.productable_id product.productable_id
json.categories product.categories