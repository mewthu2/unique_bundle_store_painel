class PreparationItem < ApplicationRecord
  # Callbacks
  enum kind: [:pending, :concluded]
  # Associacoes
  belongs_to :product
  belongs_to :product_preparation
  # Validacoes

  # Escopos

  # Metodos estaticos
  # Metodos publicos

  # Metodos GET
  # Metodos SET

  # Nota: os metodos somente utilizados em callbacks ou utilizados somente por essa
  #       propria classe deverao ser privados (remover essa anotacao)
end
