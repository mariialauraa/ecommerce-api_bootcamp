require 'cpf_cnpj'

class CpfCnpjValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)        
    return unless value.present?
    #utilizando o 'valid?' para verificar se o valor passado é um CPF ou um CNPJ válido
    unless CPF.valid?(value) || CNPJ.valid?(value)
      #e em seguida adicionando um erro caso não seja
      record.errors.add(attribute, :invalid_cpf_cnpj)
    end
  end
end